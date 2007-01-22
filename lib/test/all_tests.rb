#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'pp'
begin
  require 'term/ansicolor'
  class String
    include Term::ANSIColor
  end
rescue LoadError
  class String

    # this will be set in case term/ansicolor cannot be
    # required, just makes colorless output

    def red() self end

    # this will be set in case term/ansicolor cannot be
    # required, just makes colorless output

    def green() self end
  end
end

$stdout.sync = true

specs = 0
failures = 0
problematic = {}

Dir['test/**/tc_*.rb'].each do |test_case|
  print "rspec #{test_case.ljust(50)} "
  out = `ruby #{test_case}`
  out.split("\n").each do |line|
    if line =~ /(\d+) specifications?, (\d+) failures?/
      s, f = $1.to_i, $2.to_i

      specs    += s
      failures += f

      message = "[#{s.to_s.rjust(3)} specs | "

      if f.nonzero? or $?.exitstatus != 0
        problematic[test_case] = out
        message << "#{f.to_s.rjust(3)} failed ]"
        puts message.red
      else
        message << "all passed ]"
        puts message.green
      end
    end
  end
end

puts "-" * 80
problematic.each do |key, value|
  puts key.center(80)
  puts "v" * 80
  puts
  puts value
  puts "-" * 80
end

puts "Total: #{specs} contexts, #{failures} failures"

if problems = problematic.keys.join(', ')
  puts "These failed: #{problems}"
end
