#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'pp'

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
      puts "[#{s.to_s.rjust(3)} specs]"
      problematic[test_case] = out unless f == 0
      specs    += s
      failures += f
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

puts "Total: #{specs} specifications, #{failures} failures"
puts "failed specs: #{problematic.keys.join(', ') || 'none'}"
