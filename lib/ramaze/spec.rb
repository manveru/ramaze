require File.expand_path('../', __FILE__) unless defined?(Ramaze)

def spec_requires(*libs)
  spec_precondition 'require' do
    libs.each{|lib| require(lib) }
  end
end
alias spec_require spec_requires

def spec_precondition(name)
  yield
rescue LoadError => ex
  puts "Spec require: %p failed: %p" % [name, ex.message]
  exit 0
rescue Exception => ex
  puts "Spec precondition: %p failed: %p" % [name, ex.message]
  exit 0
end

module Ramaze
  Mock::OPTIONS[:app] = Ramaze

  middleware!(:spec){|m| m.run(AppMap) }
end

# FIXME: will remove that in 2009.07, and then we can offer integration with
#        any other test-framework we like and they can share this code.
#        Then Ramaze can be:
#          Any ruby, any ORM, any templating-engine, any test-framework
unless defined?(Bacon)
  Ramaze.deprecated "require('ramaze/spec')", "require('ramaze/spec/bacon')"
  require 'ramaze/spec/bacon'
end
