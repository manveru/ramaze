require(File.join(File.dirname(__FILE__), '../ramaze/thread_accessor'))

class Object
  include Ramaze::ThreadAccessor
end
