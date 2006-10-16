Dir['test/**/tc_*.rb'].each do |test_case|
  puts "running #{test_case}"
  require test_case

  Ramaze::Global.running_adapter.kill rescue nil
end
