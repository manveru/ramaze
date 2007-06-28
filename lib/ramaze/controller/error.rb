#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    # The default error-page handler. you can overwrite this method
    # in your controller and create your own error-template for use.
    #
    # Error-pages can be in whatever the templating-engine of your controller
    # is set to.
    #   Ramaze::Dispatcher::Error.current
    # holds the exception thrown.

    def error
      error = Ramaze::Dispatcher::Error.current
      @backtrace = error.backtrace[0..20]
      title = error.message

      @colors = []
      min = 200
      max = 255
      step = -((max - min) / @backtrace.size).abs
      max.step(min, step) do |color|
        @colors << color
      end

      backtrace_size = Ramaze::Global.backtrace_size

      @backtrace.map! do |line|
        file, lineno, meth = *Ramaze.parse_backtrace(line)
        lines = Ramaze.caller_lines(file, lineno, backtrace_size)

        [ lines, lines.object_id.abs, file, lineno, meth ]
      end

      @title = CGI.escapeHTML(title)
      @editor = (ENV['EDITOR'] || 'vim')
      title
    rescue Object => ex
      Inform.error(ex)
    end
  end
end
