require 'lib/test/test_helper'

include Ramaze

class AmritaController < Template::Amrita2
  trait :template_root => File.join(File.dirname(File.expand_path(__FILE__)), 'template', 'amrita')

  def index
    "The index"
  end
end

class RamazeController < Template::Ramaze
  def index
    "The index"
  end

  def sum first, second
    first.to_i + second.to_i
  end
end

ramaze do
  context "Testing Ramaze" do
    specify "simple request to index" do
      get('/ramaze').should == 'The index'
    end

    specify "summing two values" do
      get('/ramaze/sum/1/2').should == '3'
    end
  end

  context "Testing Amrita" do
    specify "simple request to index" do
      get('/amrita').should == "<div>The index</div>"
    end
  end
end
