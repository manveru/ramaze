require 'spec/helper'

describe 'String#/' do

  # check if this is ok in win32
  it 'should join two strings' do
    ('a' / 'b').should == 'a/b'
  end

  it 'should join a string and a symbol' do
    ('a' / :b).should == 'a/b'
  end

  it 'should be usable in concatenation' do
    ('a' / :b / :c).should == 'a/b/c'
  end

end
