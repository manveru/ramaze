#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/spec/helper/minimal'
require 'ramaze/spec/helper/mock_http'
require 'ramaze/spec/helper/simple_http'
require 'ramaze/spec/helper/requester'
require 'ramaze/spec/helper/context'

Spec::Runner.configure do |config|
  config.include MockHTTP
end


if defined?(::Spec)
  exclude = Ramaze::Controller.class_trait[:exclude_action_modules]
  exclude += [Base64::Deprecated, Base64, Spec::Expectations::ObjectExpectations]
  exclude << Spec::Mocks::Methods if defined?(Spec::Mock::Methods)
end

# start up ramaze with a given hash of options
# that will be merged with the default-options.

def ramaze_start hash = {}
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
