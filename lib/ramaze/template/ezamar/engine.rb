#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha1'

# Ezamar is a very simple (and at no means complete) reimplementation of the
# Templating-engine found in Nitro.
#
# Since Nitros templating is based on REXML and Ezamar is not there are vast
# differences, but it tries to keep the look and feel as close as possible.

module Ezamar

  require 'ramaze/template/ezamar/element'
  require 'ramaze/template/ezamar/morpher'

  # This class is responsible for initializing and compiling the template.

  class Template
    attr_accessor :last_result, :file
    attr_reader :original

    # Start a new template with some string for your template
    # that's going to be transformed.

    def initialize source, action = nil
      @source = source
      @binding, @file = action.values_at(:binding, :template) if action
      @start_heredoc = "T" << Digest::SHA1.hexdigest(@source)
      @start_heredoc, @end_heredoc = "\n<<#{@start_heredoc}\n", "\n#{@start_heredoc}\n"
      @bufadd = "_out_ << "
      @old = true
      compile
    end

    # reset the original template you gave

    def original=(original)
      compile
    end

    # is the template old?

    def old?
      !!@old
    end

    # make the template old - mark it for recompilation.

    def touch
      @old = true
    end

    # transform a String to a final xhtml
    #
    # You can pass it a binding, for example from your controller.
    #
    # Example:
    #
    #   class Controller
    #     def hello
    #       @hello = 'Hello, World!'
    #     end
    #   end
    #
    #   controller = Controller.new
    #   controller.hello
    #   binding = controller.send(:binding)
    #
    #   Ezamar.new('#{@hello}').transform(binding)

    def transform(_binding_ = @binding)
      @compiled = compile if old?

      args = @file ? [@file] : []

      @last_result = eval(@compiled, _binding_, *args)

      @last_result.map! do |line|
        line.to_s.chomp
      end

      @last_result = @last_result.join.strip
    end

    # The actual compilation of the @source
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
    # The result of the compilation will be stored in @compiled.

    def compile
      @source.gsub!(/<%\s+(.*?)\s+%>/m,
          "#{@end_heredoc} \\1; #{@bufadd} #{@start_heredoc}")
      @source.gsub!(/<\?r\s+(.*?)\s+\?>/m,
          "#{@end_heredoc} \\1; #{@bufadd} #{@start_heredoc}")
      @source.gsub!(/<%=\s+(.*?)\s+%>/m,
          "#{@end_heredoc} #{@bufadd} (\\1); #{@bufadd} #{@start_heredoc}")

      @source = [@bufadd, @start_heredoc, @source, @end_heredoc].join(' ')

      @old = false
      @compiled = "_out_ = []; #{@source}; _out_"
    end
  end
end
