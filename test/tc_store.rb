require 'ramaze'
require 'test/test_helper'
require 'ramaze/store/default'

include Ramaze

context "initialize an Store" do
  specify "Store::Default.new" do
    Db = Store::Default.new
    Db.db.should.is_a?(YAML::Store)
  end

  specify "store and retrieve something" do
    (Db[:foo] = :bar).should == :bar
    Db[:foo].should == :bar
  end
end
