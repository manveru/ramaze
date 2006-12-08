require 'ramaze'
require 'ramaze/../test/test_helper'

require 'main'

ramaze do
  context "Entry" do
    specify "list" do
      get('/entry').should =~ %r(<h1>Entry list</h1>)
    end

    specify "add" do
      new = get('/entry/new')
      new.should =~ %r(<input type="text")
      new.should =~ %r(<textarea name="text")
    end
  end
end
