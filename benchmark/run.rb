__DIR__ = File.expand_path(File.dirname(__FILE__))
class String
  def /(o) File.join(self, o.to_s) end
end

results = File.open(__DIR__/'results.txt', 'w')

%w[ simple no_template no_informer no_sessions minimal ].each do |file|

  filename = __DIR__/:suite/"#{file}.rb"

  results.puts "====== #{file} ======"
  results.puts "<code ruby>\n#{File.read(filename)}\n</code>\n\n"

  adapters = case file
             when 'simple': %w[ webrick mongrel ]
             else []
             end << 'evented_mongrel'

  adapters.each do |adapter|

    results.puts "=== #{adapter} ==="

    ramaze = fork do
      require filename
      Ramaze.start :adapter => adapter
    end

    # wait for ramaze to start up
    sleep 1

    results.puts `ab -c 10 -n 1000 http://127.0.0.1:7000/`.grep(/^(Fail|Req|Time)/).map{|l|"  #{l}"}
    results.puts "\n"
    results.flush

    Process.kill('SIGKILL', ramaze)
    Process.waitpid2(ramaze)
  end
end

results.close