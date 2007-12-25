#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

describe 'Symbol#to_proc' do
  it 'should convert symbols to procs' do
    [:one, :two, :three].map(&:to_s).should == %w[ one two three ]
  end

  it 'should work with list objects' do
    { 1 => "one",
      2 => "two",
      3 => "three" }.sort_by(&:first).map(&:last).should == %w[ one two three ]
  end
end