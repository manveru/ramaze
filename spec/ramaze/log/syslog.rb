require 'spec/helper'

require 'ramaze/log/syslog'

describe 'Syslog' do
  it 'should do something' do
    syslog = Ramaze::Logging::Logger::Syslog.new
    syslog.send(:ident).should =~ /#{Regexp.escape(__FILE__)}$/
  end
end
