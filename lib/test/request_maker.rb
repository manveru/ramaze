#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

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
