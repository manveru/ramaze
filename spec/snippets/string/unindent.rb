require 'spec'
require File.expand_path(__FILE__).gsub(/\/spec\//, '/lib/ramaze/')

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

  it 'should not break on a single line' do
    'word'.unindent.should == 'word'
  end
end
