require 'ramaze'
require 'test/test_helper'

include Ramaze

class MainController < Template::Amrita2
  def data
    [  
      { :name=>"Ruby", :author=>"matz" },              
      { :name=>"perl", :author=>"Larry Wall" },        
      { :name=>"python", :author=>"Guido van Rossum" },
    ]                                                   
  end
end

start
sleep 0.5

context "Simply calling" do
  def request opt
    open("http://localhost:#{Ramaze::Global.port}/#{opt}").read
  end

  specify "should respond to /data" do
    request('/data').should_equal 'no params'
  end
end
