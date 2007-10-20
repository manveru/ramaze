results = File.open('benchmarks.txt', 'w')

%w{ simple no_informer no_template no_informer_or_template }.each do |file|
  
  filename = "#{file}.rb"
  
  results.puts "====== #{filename} ======"
  results.puts "<code ruby>\n#{File.read(filename)}\n</code>\n\n"
  
  %w{ webrick mongrel evented_mongrel }.each do |adapter|
    
    results.puts "=== #{adapter} ==="
    
    ramaze = fork do
      Signal.trap('USR1') { Ramaze.shutdown }
      require file
      Ramaze.start :adapter => adapter
    end

    # wait for ramaze to start up
    sleep 2
    
    results.puts `ab -c 10 -n 1000 http://localhost:7000/`.grep(/^(Fail|Req|Time)/).map{|l|"  #{l}"}
    results.puts "\n"
    results.flush
    
    Process.kill('USR1', ramaze)
    
    # wait for ramaze to shut down
    sleep 2
  end
end

results.close