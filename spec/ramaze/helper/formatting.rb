require 'spec/helper'
require 'ramaze/helper/formatting'

describe 'Helper::Formatting' do
  extend Ramaze::Helper::Formatting

  it 'should format numbers' do
    number_format(2_123_456).should == '2,123,456'
    number_format(1234.567).should == '1,234.567'
    number_format(123456.789, '.').should == '123.456,789'
    number_format(123456.789123, '.').should == '123.456,789123'
    number_format(132123456.789123, '.').should == '132.123.456,789123'
  end

  it 'should return difference in time as a string' do
    time_diff(Time.now-29).should == 'less than a minute'
    time_diff(Time.now-60).should == '1 minute'
    time_diff(Time.now, Time.now+29, true).should == 'half a minute'
  end

  it 'should linkify urls' do
    auto_link("http://ramaze.net is the coolest framework, but <a href='http://merbivore.com'>merb</a> is good too").should ==
      "<a href=\"http://ramaze.net\">http://ramaze.net</a> is the coolest framework, but <a href='http://merbivore.com'>merb</a> is good too"

    auto_link("http://ramaze.net", :target => '_blank').should ==
      "<a href=\"http://ramaze.net\" target='_blank'>http://ramaze.net</a>"
  end
end
