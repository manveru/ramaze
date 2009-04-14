begin; require 'rubygems'; rescue LoadError; end

require(File.expand_path("#{__FILE__}/../")) unless defined?(Ramaze)
require 'innate/spec'

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

shared :mock do
  Ramaze.setup_dependencies
  extend Rack::Test::Methods

  def app; Ramaze.middleware; end
end
