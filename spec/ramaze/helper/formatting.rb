require 'spec/helper'
require 'ramaze/helper/formatting'

describe 'FormattingHelper' do
  include Ramaze::FormattingHelper

  it 'should format numbers' do
    number_format(2_123_456).should == '2,123,456'
    number_format(1234.567).should == '1,234.567'
    number_format(123456.789, '.').should == '123.456,789'
  end

  it 'should return difference in time as a string' do
    time_diff(Time.now-29).should == 'less than a minute'
    time_diff(Time.now-60).should == '1 minute'
    time_diff(Time.now, Time.now+29, true).should == 'half a minute'
  end
end