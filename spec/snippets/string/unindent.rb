require 'spec/helper'

describe "String#unindent" do
  it "should remove indentation" do
    %(
      hello
        how
          are
        you
      doing
    ).ui.should == \
%(hello
  how
    are
  you
doing)
  end
end