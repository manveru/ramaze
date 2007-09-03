require 'spec/helper'

describe '__DIR__' do
  # this is hardly exhaustive, but better tha anything
  it 'should report the directory of the current file' do
    __DIR__.should == File.dirname(File.expand_path(__FILE__))
  end
end
