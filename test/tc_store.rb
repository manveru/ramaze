require 'ramaze'
require 'test/test_helper'
require 'ramaze/store/default'

include Ramaze

context "initialize an Store" do
  db = 'db.yaml'

  specify "Store::Default.new" do
    Db = Store::Default.new(db)
    Db.db.should.is_a?(YAML::Store)
  end

  specify "store and retrieve something" do
    (Db[:foo] = :bar).should == :bar
    Db[:foo].should == :bar
  end

  teardown do
    FileUtils.rm db
  end
end
