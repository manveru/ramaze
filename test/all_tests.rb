specs = 0
failures = 0

Dir['test/**/tc_*.rb'].each do |test_case|
  puts "rspec #{test_case}"
  out = `ruby #{test_case}`
  out.split("\n").each do |line|
    if line =~ /(\d+) specifications, (\d+) failures/ 
      specs    += $1.to_i
      failures +=  $2.to_i
    end
  end
end

puts "Total: #{specs} specifications, #{failures} failures"
