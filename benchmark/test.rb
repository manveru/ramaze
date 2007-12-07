# Usage:
#   $ ruby benchmark/test.rb
#
# or with darcs trackdown
#   $ cp benchmark/test.rb /tmp/bm.rb
#   $ darcs trackdown 'ruby /tmp/bm.rb; false'

begin
  require File.join(Dir.pwd, 'lib/ramaze')
rescue LoadError
  raise "Can't find lib/ramaze, are you in a ramaze src directory?"
end

ramaze = fork do
  class MainController < Ramaze::Controller
    engine :None
    def index() "Hello, World!" end
  end

  Ramaze::Inform.loggers = []
  Ramaze.start :adapter => :evented_mongrel, :sessions => false
end

sleep 2
out = `ab -c 10 -n 1000 http://127.0.0.1:7000/ 2> /dev/null`
Process.kill('SIGKILL', ramaze)

out =~ /^Requests.+?(\d+\.\d+)/
puts $1

Process.wait