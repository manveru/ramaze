require 'spec/helper'

require 'ramaze/log/syslog'

describe 'Syslog' do
  it 'should do something' do
    syslog = Ramaze::Syslog.new
    syslog.send(:ident).should =~ /#{Regexp.escape(__FILE__)}$/
  end
end
