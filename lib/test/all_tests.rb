require 'pp'

$stdout.sync = true

specs = 0
failures = 0
problematic = {}

Dir['test/**/tc_*.rb'].each do |test_case|
  out = `ruby #{test_case}`
  out.split("\n").each do |line|
    if line =~ /(\d+) specifications?, (\d+) failures?/ 
      s, f = $1.to_i, $2.to_i
      puts "rspec #{test_case} [#{s} specs]"
      problematic[test_case] = out unless f == 0
      specs    += s
      failures += f
    end
  end
end

problematic.each do |key, value|
  puts "-" * 80
  puts key
  puts value
  puts "-" * 80
end

puts "Total: #{specs} specifications, #{failures} failures"
puts "failed specs: #{problematic.keys.join(', ') || 'none'}"
