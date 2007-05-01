require 'spec/helper'

require 'ramaze/inform/syslog'

describe 'Syslog' do
  it 'should do something' do
    syslog = Ramaze::Syslog.new
    syslog.send(:ident).should =~ /#{__FILE__}$/
  end
end
