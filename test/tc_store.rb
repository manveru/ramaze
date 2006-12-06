#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'
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
