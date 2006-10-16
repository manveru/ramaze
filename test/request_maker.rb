require 'open-uri'
require 'pp'

loop do
  print 'do request? [enter] '
  gets
  begin
    pp open('http://localhost:7000/xxx').read
  rescue Object => ex
    puts ex
  end
end
