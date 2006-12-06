#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze::Template
  class Ramaze
    trait :actionless => false

    class << self

      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request request, action, *params
        controller = self.new
        template = controller.__send__(action, *params).to_s
        rendered = controller.__send__(:render, action).to_s
        template = rendered unless rendered.empty?
        template
      end

      # This loads the helper-files from /ramaze/helper/helpername.rb and
      # includes it into Ramaze::Template (or wherever it is called)
      #
      # Usage:
      #   helper :redirect, :link

      def helper *syms
        syms.each do |sym|
          load "ramaze/helper/#{sym}.rb"
          include ::Ramaze.const_get("#{sym.to_s.capitalize}Helper")
        end
      end
    end

    private

    include Trinity

    helper :link, :redirect

    def breakout
      nil
    end

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
    #   - the template_root should be defineable per controller, without the magic
    #     so a
    #     trait :controller_root => 'template/foo'
    #     should be made possible
    #   - maybe add some way to define a custom template-file per action via traits
    #     trait :methodname_template => :foo
    #     would point to the template-file of action :foo - template_root/foo.ext
    #   - add extensive tests!
    #

    def render action
      path = File.join(Global.template_root, Global.mapping.invert[self.class], action)

      exts = %w[rmze xhtml html]

      files = exts.map{|ext| "#{path}.#{ext}"}
      file = files.find{|file| File.file?(file)}.to_s

      return '' unless File.exist?(file)

      info "transforming #{file}"
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
    # #[ rubycode ]
    #   In theory, this should just act like #{} - it's neither neccesary nor does
    #   it give you any advantages. Will most likely be removed as it was just an
    #   experiment.
    #   Don't use it :)
    #
    # Warning:
    # the variables used in here have the schema _variable_ to make it harder to break stuff
    # however, you should take care.
    # At the time of writing, the variables used are:
    # _start_heredoc_, _end_heredoc_, _string_, _out_, _bufadd_
    #

    def transform _string_, _ivs_ = {}
      _ivs_.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      _start_heredoc_, _end_heredoc_ = "\n<<FOOBARABOOF_RAMAZE\n", "\nFOOBARABOOF_RAMAZE\n"
      _bufadd_ = "_out_ << "
      begin
        _string_.gsub!(/<% (.*?) %>/) do |m|
          "#{_end_heredoc_} #{$1}; #{_bufadd_} #{_start_heredoc_}"
        end

        _string_.gsub!(/<\?r (.*?) \?>/) do |m|
          "#{_end_heredoc_} #{$1}; #{_bufadd_} #{_start_heredoc_}"
        end

        _string_.gsub!(/<%= (.*?) %>/) do |m|
          "#{_end_heredoc_} #{_bufadd_} (#{$1}); #{_bufadd_} #{_start_heredoc_}"
        end

        # this one should not be used until we find and solution
        # that allows for stuff like
        # #[@foo]!
        # we just don't allow anything except space or newline
        # after the expression #[] to make it sane
        _string_.gsub!(/#\[(.*?)\]\s*$/) do |m|
          "#{_end_heredoc_} #{_bufadd_} (#{$1}); #{_bufadd_} #{_start_heredoc_}"
        end

        _out_ = []

        eval("#{_bufadd_} #{_start_heredoc_} #{_string_} #{_end_heredoc_}")

        _out_.map! do |line|
          line.to_s.chomp
        end
        _string_ = _out_.join.strip
      rescue Object => ex
        error "something bad happened while transformation"
        error ex
      end
      _string_
    end
  end
end
