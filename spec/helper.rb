#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')
$:.unshift '/home/manveru/prog/projects/rack/lib'

# $VERBOSE = 1
$context_runner = false

require 'ramaze'

begin
  require 'rubygems'
rescue LoadError => ex
end

require 'spec'
if Spec::VERSION::FULL_VERSION < "0.9.1 (r1880)"
  puts "please update rspec >= 0.9.1"
  exit 1
end

require 'spec/helper/mock_http'
require 'spec/helper/simple_http'
require 'spec/helper/requester'
require 'spec/helper/context'

Spec::Runner.configure do |config|
  config.include MockHTTP
end

# start up ramaze with a given hash of options
# that will be merged with the default-options.

def ramaze_start hash = {}
  options = {
    :mode         => :debug,
    :adapter      => false,
    :run_loose    => true,
    :error_page   => false,
    :port         => 7007,
    :host         => '127.0.0.1',
    :force        => true,
    :force_setup  => true,
  }.merge(hash)

  Ramaze.start(options)
end

alias ramaze ramaze_start

# shutdown ramaze, this is not implemeted yet
# (and might never be due to limited possibilites)

def browser(*args, &block)
  Browser.new(*args, &block)
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
