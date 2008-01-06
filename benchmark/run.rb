__DIR__ = File.expand_path(File.dirname(__FILE__))
class String
  def /(o) File.join(self, o.to_s) end
end

def memsize(pid)
  (`ps -p #{pid} -o rss=`.strip.to_f/10.24).round/100.0
end

PORT = rand(32768-1)+32768
REQUESTS = 100
CONCURRENT = 10
SIGNAL = 'SIGKILL'

class Results
  def initialize(*a) @a = a end
  def method_missing(*a) @a.each {|x| x.__send__(*a) } end
end

results = Results.new(File.open(__DIR__/'results.txt', 'w'), $stderr)

Dir[__DIR__/"suite"/"*.rb"].each do |filename|
  file = filename.scan(/\/([^\/]+)\.rb/).to_s
  next if ARGV.size > 0 && !ARGV.include?(file)

  results.puts "====== #{file} ======"
  results.puts "<code ruby>\n#{File.read(filename)}\n</code>\n\n"

  adapters = case file
             when 'simple' then %w[ webrick mongrel ]
             else []
             end << 'evented_mongrel'

  adapters.each do |adapter|

    results.puts "=== #{adapter} ==="

    ramaze = fork do
      require filename
      Ramaze.start :adapter => adapter, :port => PORT
    end

    # wait for ramaze to start up
    sleep 1

    results.puts "  Mem usage before:".ljust(26) + "#{memsize(ramaze)}MB"
    results.puts `ab -c #{CONCURRENT} -n #{REQUESTS} http://127.0.0.1:#{PORT}/`.grep(/^(Fail|Req|Time)/).map{|l|"  #{l}"}
    results.puts "  Mem usage after:".ljust(26)  + "#{memsize(ramaze)}MB"

    results.puts "\n"
    results.flush

    Process.kill(SIGNAL, ramaze)
    Process.waitpid2(ramaze)
  end
end

results.close
