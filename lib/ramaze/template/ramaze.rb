#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha1'
require 'ramaze/template/ramaze/element'
require 'ramaze/template/ramaze/morpher'

module Ramaze::Template

  # The usual Template for use of Ramaze.
  # It supports erb-style interpolation and a pipeline for the transform

  class Ramaze < Template
    trait :actionless => false
    trait :template_extensions => %w[rmze xhtml rhtml html]
    trait :transform_pipeline => [
      Element,
      Morpher,
      self
    ]

    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request(action, *params)
        controller = self.new
        controller.send(:render, action, *params)
      end

      # in case someone wants to call directly (pipeline)

      def transform(template, bound)
        self.new.send(:transform, template, bound)
      end
    end

    private

    # render an action
    # this looks up the file depending on your Global.template_root
    # and also takes the mapping of the controller in account.
    # To use the exception of method_missing as flow-control might seem odd,
    # but it works perfect for method_missing defined in the controller...
    # otherwise one has to modify respond_to?... maybe add a special take-all method?
    #
    # for example:
    # / => FooController, /main => MainController
    # an action to /bar would search directly in the template_root for a file called bar
    # and the extensions rmze, xhtml or html (in that order)
    # if it finds a file it will transform it and return the result
    # otherwise nothing happens
    #
    # TODO:
    #   - maybe add some way to define a custom template-file per action via traits
    #     trait :methodname_template => :foo
    #     would point to the template-file of action :foo - template_root/foo.ext
    #   - add extensive tests!
    #

    def render(action, *params)
      alternate = render_template(params.last) if params.size == 1 and action == 'index'
      file_template = render_template(action, *params)
      ctrl_template = render_action(action, *params)

      pipeline(alternate || file_template || ctrl_template)
    end

    # Render an action, usually a method on the controller.

    def render_action(action, *params)
      ctrl_template = send(action, *params).to_s
    rescue => e
      Informer.error e unless e.message =~ /undefined method `#{Regexp.escape(action.to_s)}'/

      unless caller.select{|bt| bt[/`render_action'/]}.size > 3
        Dispatcher.respond_action([action, *params].join('/'))
        ctrl_template = response.out
      end
    end

    # Render the template.

    def render_template(action, *params)
      File.read(find_template(action)) rescue nil
    end

    # go through the pipeline and call #transform on every object found there,
    # passing the template at that point.
    # the order and contents of the pipeline are determined by an array
    # in trait[:template_pipeline]
    # the default being [self, Element]

    def pipeline(template)
      transform_pipeline = ancestral_trait[:transform_pipeline]

      transform_pipeline.inject(template) do |memo, current|
        current.transform(memo, binding)
      end
    end

    # transform a String to a final xhtml
    #
    # All ye who seek magic, look elsewhere, this method is ASAP (as simple as possible)
    #
    # There are some simple gsubs that build a final template which is evaluated
    #
    # The rules are following:
    # <?r rubycode ?>
    #   evaluate the code inside the tag, this is considered XHTML-valid and so is the
    #   preferred method for executing code inside your templates.
    #   The return-value is ignored
    # <% rubycode %>
    #   The same as <?r ?>, ERB-style and not valid XHTML, but should give someone who
    #   is already familiar with ERB some common ground
    # #{ rubycode }
    #   You know this from normal ruby already and it's actually nothing else.
    #   Interpolation at the position in the template, isn't any special taggy format
    #   and therefor safe to use.
    # <%= rubycode %>
    #   The result of this will be interpolated at the position in the template.
    #   Not valid XHTML either.
    #
    # Warning:
    # the variables used in here have the schema _variable_ to make it harder to break stuff
    # however, you should take care.
    # At the time of writing, the variables used are:
    # _start_heredoc_, _end_heredoc_, _template_, _out_, _file_ and _bufadd_
    # However, you may reuse _ivs_ if you desperatly need it and just can't live without.
    #

    def transform(_template_, _binding_ = binding)
      _start_heredoc_ = "T" << Digest::SHA1.hexdigest(_template_)
      _start_heredoc_, _end_heredoc_ = "\n<<#{_start_heredoc_}\n", "\n#{_start_heredoc_}\n"
      _bufadd_ = "_out_ << "

      _file_, _template_ = _template_, File.read(_template_) if File.file?(_template_)

      _template_.gsub!(/<%\s+(.*?)\s+%>/m,
          "#{_end_heredoc_} \\1; #{_bufadd_} #{_start_heredoc_}")
      _template_.gsub!(/<\?r\s+(.*?)\s+\?>/m,
          "#{_end_heredoc_} \\1; #{_bufadd_} #{_start_heredoc_}")

      _template_.gsub!(/<%=\s+(.*?)\s+%>/m,
          "#{_end_heredoc_} #{_bufadd_} (\\1); #{_bufadd_} #{_start_heredoc_}")


      # this one should not be used until we find and solution
      # that allows for stuff like
      # #[@foo]!
      # we just don't allow anything except space or newline
      # after the expression #[] to make it sane
      #_template_.gsub!(/#\[(.*?)\]\s*$/) do |m|
      #  "#{_end_heredoc_} #{_bufadd_} (#{$1}); #{_bufadd_} #{_start_heredoc_}"
      #end

      _template_ = [_bufadd_, _start_heredoc_, _template_, _end_heredoc_].join(' ')
      _out_ = eval(*["_out_ = []; #{_template_}; _out_", _binding_, _file_].compact)

      _out_.map! do |line|
        line.to_s.chomp
      end

      _template_ = _out_.join.strip
    rescue Object => ex
      Informer.error "something bad happened while transformation"
      Informer.error ex
      #raise Error::Template, "Problem during transformation for: #{request.request_path}"
      {ex.message => _template_}.inspect
    end

  end
end
