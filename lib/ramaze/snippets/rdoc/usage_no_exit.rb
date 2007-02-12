#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rdoc/ri/ri_paths'
require 'rdoc/usage'

# This is a little hack to enable RDoc to see through gems.
#
# Very evil, but until we get a better RDoc this will have to do.

module RDoc
  class << self
    def ramazes_usage(*args)
      exit_code = 0

      if args.size > 0
        status = args[0]
        if status.respond_to?(:to_int)
          exit_code = status.to_int
          args.shift
        end
      end

      # display the usage and exit with the given code
      ramazes_usage_no_exit(*args)
      exit(exit_code)
    end

    def ramazes_usage_no_exit(*args)
      main_program_file = caller[1].sub(/:\d+$/, '')
      comment = File.open(main_program_file) do |file|
        find_comment(file)
      end

      comment = comment.gsub(/^\s*#/, '')

      markup = SM::SimpleMarkup.new
      flow_convertor = SM::ToFlow.new

      flow = markup.convert(comment, flow_convertor)

      format = "plain"

      unless args.empty?
        flow = extract_sections(flow, args)
      end

      options = RI::Options.instance
      if args = ENV["RI"]
        options.parse(args.split)
      end
      formatter = options.formatter.new(options, "")
      formatter.display_flow(flow)
    end
  end
end
