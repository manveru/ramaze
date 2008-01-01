#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

begin
  require 'rubygems'
rescue LoadError => ex
end

require 'timeout'

require 'ramaze'
require 'ramaze/spec/helper/bacon'

def ramaze(options = {})
  appdir = File.dirname(caller[0].split(':').first)
  options = {
    :template_root => appdir/:template,
    :public_root => appdir/:public,
    :adapter      => false,
    :run_loose    => true,
    :error_page   => false,
    :port         => 7007,
    :host         => '127.0.0.1',
    :force        => true,
    :origin       => :spec,
  }.merge(options)

  Ramaze.start(options)
end

# require each of the following and rescue LoadError, telling you why it failed.

def testcase_requires(*following)
  following.each do |file|
    require(file.to_s)
  end
rescue LoadError => ex
  puts ex
  puts "Can't run #{$0}: #{ex}"
  puts "Usually you should not worry about this failure, just install the"
  puts "library and try again (if you want to use that feature later on)"
  exit
end


shared "http" do
  require 'ramaze/spec/helper/mock_http'
  extend MockHTTP
end

shared 'browser' do
  require 'ramaze/spec/helper/simple_http'
  require 'ramaze/spec/helper/browser'
end

shared 'requester' do
  require 'ramaze/spec/helper/requester'
end
