require 'ramaze'
require 'bacon'

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
