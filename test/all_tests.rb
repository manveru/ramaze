Dir['test/**/tc_*.rb'].each do |test_case|
  puts "running #{test_case}"
  system("ruby #{test_case}")
end
