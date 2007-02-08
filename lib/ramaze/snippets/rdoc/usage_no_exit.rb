#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# This is a little hack to enable RDoc to see through gems.
#
# Very evil, but until we get a better RDoc this will have to do.

require 'rdoc/ri/ri_paths'
require 'rdoc/usage'

def RDoc.usage_no_exit(*args)
  p caller
  main_program_file = caller[1].sub(/:\d+$/, '')
  p main_program_file
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

