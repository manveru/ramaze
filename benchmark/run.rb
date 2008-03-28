require "optparse"

class String
  def /(o) File.join(self, o.to_s) end
end

class RamazeBenchmark
  attr_reader :results
  attr_accessor :requests, :adapter, :port, :log, :display_code, :target

  def initialize()
    @adapter = :webrick
    @port = rand(32768-1)+32768
    @requests = 100
    @concurrent = 10
    @signal = 'SIGKILL'
    @log = false
    @display_code = false
    @target = nil
  end

  def start
    __DIR__ = File.expand_path(File.dirname(__FILE__))
    Dir[__DIR__/"suite"/"*.rb"].each do |filename|
      next unless @target.kind_of?(Regexp) and @target.match(filename)
      benchmark(filename, @adapter)
    end
  end

  def memsize(pid)
    (`ps -p #{pid} -o rss=`.strip.to_f/10.24).round/100.0
  end

  def l(line = "\n")
    puts line
  end

  def flush
    $stdout.flush
  end

  def ab
    `ab -c #{@concurrent} -n #{@requests} http://127.0.0.1:#{@port}/`.split("\n")
  end

  def benchmark(filename, adapter)
    file = filename.scan(/\/([^\/]+)\.rb/).to_s
    #next if ARGV.size > 0 && !ARGV.include?(file)

    l "====== #{file} ======"
    l "Adapter:".ljust(24) + adapter.to_s
    l "Requests:".ljust(24) + @requests.to_s
    l "Concurrent:".ljust(24) + @concurrent.to_s
    if @display_code
      l "<code ruby>\n#{File.read(filename)}\n</code>\n\n"
    end

    ramaze = fork do
      begin
        require filename
        unless @log
          Ramaze::Log.loggers = []
        end
        Ramaze.start :adapter => adapter, :port => @port
      rescue LoadError => ex
        l "ERROR: " + ex.to_s
      end
    end

    # wait for ramaze to start up
    sleep 1

    l "Mem usage before:".ljust(24) + "#{memsize(ramaze)}MB"
    l ab.grep(/^(Fail|Req|Time)/)
    l "Mem usage after:".ljust(24)  + "#{memsize(ramaze)}MB"
    l

    flush

    Process.kill(@signal, ramaze)
    Process.waitpid2(ramaze)
  end
end

$bm = RamazeBenchmark.new

OptionParser.new do |opt|
  opt.on('-a', '--adapter [name]') do |adapter|
    $bm.adapter = adapter
  end

  opt.on('-r', '--request-size [n]') do |n|
    $bm.requests = n
  end

  opt.on('-c', '--concurrent [n]') do |n|
    $bm.concurrent = n
  end

  opt.on('--code') do |n|
    $bm.display_code = true
  end

  opt.on('-p', '--port [n]') do |n|
    $bm.port = n
  end

  opt.on('-l', '--log') do |log|
    $bm.log = log
  end

  opt.on('--target [name]') do |name|
    $bm.target = Regexp.compile(name)
  end

  opt.on('-h', '--help') do
    puts opt.help
    exit
  end
end.parse!(ARGV)

$bm.start
