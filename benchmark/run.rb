require "optparse"
require "timeout"
require "net/http"

class String
  def /(o) File.join(self, o.to_s) end
end

class RamazeBenchmark
  attr_accessor :requests, :adapter, :port, :log, :display_code, :target
  attr_accessor :concurrent, :path, :benchmarker

  def initialize()
    @adapter = :webrick
    @port = rand(32768-1)+32768
    @requests = 100
    @concurrent = 10
    @signal = 'SIGKILL'
    @log = false
    @display_code = false
    @target = nil
    @host = "localhost"
    @path = "/"
    @target = /.+/
    @ljust = 24
    yield self
  end

  def start
    __DIR__ = File.expand_path(File.dirname(__FILE__))
    Dir[__DIR__/"suite"/"*.rb"].each do |filename|
      benchmark(filename) if @target.match(filename)
    end
  end

  # start to measure
  def benchmark(filename)
    file = filename.scan(/\/([^\/]+)\.rb/).to_s

    l "====== #{file} ======"
    l :Adapter,    @adapter
    l :Requests,   @requests
    l :Concurrent, @concurrent
    l :Path,       @path
    l "<code ruby>\n#{File.read(filename)}\n</code>\n\n" if @display_code

    ramaze(filename) do |pid|
      l "Mem usage before", "#{memsize(pid)}MB"
      l ab.grep(/^(Fail|Req|Time)/)
      l "Mem usage after", "#{memsize(pid)}MB"
      l
    end
  end

  private

  # memory usage size
  def memsize(pid)
    (`ps -p #{pid} -o rss=`.strip.to_f/10.24).round/100.0
  end

  # output
  def l(line = "\n", val = nil)
    puts (val ? (line.to_s + ":").ljust(@ljust) + val.to_s : line)
  end

  # url of ramaze server
  def url
    "http://#{@host}:#{@port}#{@path}"
  end

  # apache benchmark
  def ab
    `ab -c #{@concurrent} -n #{@requests} #{url}/`.split("\n")
  end

  # startup
  def ramaze(filename)
    pid = fork do
      begin
        require filename
        Ramaze::Log.loggers = [] unless @log
        Ramaze.start :adapter => adapter, :port => @port
      rescue LoadError => ex; l :Error, ex; end
    end

    yield pid if wait_to_startup

    Process.kill(@signal, pid)
    Process.waitpid2(pid)
  end

  # wait for ramaze to start up
  def wait_to_startup
    begin
      Timeout.timeout(5) do
        loop do
          begin
            sleep 1; Net::HTTP.new(@host, @port).head("/"); return true
          rescue Errno::ECONNREFUSED; end
        end
      end
    rescue TimeoutError
      l "Error", "failed to start benchmark script"; return false
    end
  end
end

RamazeBenchmark.new do |bm|
  OptionParser.new do |opt|
    opt.on('-a', '--adapter NAME', '[webrick] Specify adapter') do |adapter|
      bm.adapter = adapter
    end

    opt.on('-n', '--requests NUM', '[100] Number of requests') do |n|
      bm.requests = n
    end

    opt.on('-c', '--concurrent NUM', '[10] Number of multiple requests') do |n|
      bm.concurrent = n
    end

    opt.on('--code', 'Display benchmark code') do |n|
      bm.display_code = true
    end

    opt.on('-p', '--port NUM', '[random(32768-65535)] Specify port number') do |n|
      bm.port = n
    end

    opt.on('--path PATH', '[/] Specify request path') do |path|
      bm.path = path
    end

    opt.on('-l', '--log', 'Display server log') do |log|
      bm.log = true
    end

    opt.on('--target REGEXP', '[/.+/] Specify benchmark scripts to measure') do |name|
      bm.target = Regexp.compile(name)
    end

    opt.on('-h', '--help', 'Show this message') do
      puts opt.help
      exit
    end
  end.parse!(ARGV)
end.start
