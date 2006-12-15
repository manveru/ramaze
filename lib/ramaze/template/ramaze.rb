#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha1'
require 'ramaze/template/ramaze/element'

module Ramaze::Template
  class Ramaze < Template
    trait :actionless => false
    trait :template_extensions => %w[rmze xhtml rhtml html]


    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request request, action, *params
        controller = self.new
        controller.instance_variable_set('@action', action)
        template = controller.__send__(action, *params).to_s
        rendered = controller.__send__(:render, action).to_s
        template = rendered unless rendered.empty?
        template
      end
    end

    private

    # render an action
    # this looks up the file depending on your Global.template_root
    # and also takes the mapping of the controller in account
    #
    # for example:
    # / => FooController, /main => MainController
    # an action to /bar would search directly in the template_root for a file called bar
    # and the extensions rmze, xhtml or html (in that order)
    # if it finds a file it will transform it and return the result
    # otherwise nothing happens
    #
    # TODO:
    #   - the extensions should be user-defineable, add a Global for it
    #   - add AOP capabilities
    #     pre ;index, :on => [:foo, :bar]
    #     post :index, :on => :all, :except => [:foo, :bar]
    #   - maybe add some way to define a custom template-file per action via traits
    #     trait :methodname_template => :foo
    #     would point to the template-file of action :foo - template_root/foo.ext
    #   - add extensive tests!
    #

    def render action
      path = File.join(Global.template_root, Global.mapping.invert[self.class], action.to_s)

      return '' unless file = self.class.find_template(action)

      info "transforming #{file.gsub(Dir.pwd, '.')}"
      transform(File.read(file))
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
    # _start_heredoc_, _end_heredoc_, _string_, _out_, _bufadd_ and _ivs_
    # However, you may reuse _ivs_ if you desperatly need it and just can't live without.
    #

    def transform _string_, _ivs_ = {}, binding = binding
      _ivs_.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      _start_heredoc_ = Digest::SHA1.hexdigest(_string_)
      _start_heredoc_, _end_heredoc_ = "\n<<#{_start_heredoc_}\n", "\n#{_start_heredoc_}\n"
      _bufadd_ = "_out_ << "
      begin
        _string_ = Element.transform(_string_)

        _string_.gsub!(/<%\s+(.*?)\s+%>/m,
          "#{_end_heredoc_} \\1; #{_bufadd_} #{_start_heredoc_}")
        _string_.gsub!(/<\?r\s+(.*?)\s+\?>/m,
          "#{_end_heredoc_} \\1; #{_bufadd_} #{_start_heredoc_}")

        _string_.gsub!(/<%=\s+(.*?)\s+%>/m,
          "#{_end_heredoc_} #{_bufadd_} (\\1); #{_bufadd_} #{_start_heredoc_}")


        # this one should not be used until we find and solution
        # that allows for stuff like
        # #[@foo]!
        # we just don't allow anything except space or newline
        # after the expression #[] to make it sane
        #_string_.gsub!(/#\[(.*?)\]\s*$/) do |m|
        #  "#{_end_heredoc_} #{_bufadd_} (#{$1}); #{_bufadd_} #{_start_heredoc_}"
        #end

        _out_ = []

        eval("#{_bufadd_} #{_start_heredoc_} #{_string_} #{_end_heredoc_}", binding)

        _out_.map! do |line|
          line.to_s.chomp
        end
        _string_ = _out_.join.strip
      rescue Object => ex
        error "something bad happened while transformation"
        error ex
        #raise Error::Template, "Problem during transformation for: #{request.request_path}"
      end
      _string_
    end
  end
end
