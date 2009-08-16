begin
  require 'bacon'
rescue LoadError
  require 'rubygems'
  require 'bacon'
end

require File.expand_path('../', __FILE__) unless defined?(Ramaze)

require 'innate/spec/bacon'

# minimal middleware, no exception handling
Ramaze.middleware!(:spec){|m|
  m.run(Ramaze::AppMap)
}

shared :rack_test do
  Ramaze.setup_dependencies
  extend Rack::Test::Methods

  def app; Ramaze.middleware; end
end

shared :webrat do
  behaves_like :rack_test

  require 'webrat'

  Webrat.configure{|config| config.mode = :rack }

  extend Webrat::Methods
  extend Webrat::Matchers
end
