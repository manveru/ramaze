require 'spec/helper'
require 'ramaze/helper/bench'

describe Ramaze::Helper::Bench do
  extend Ramaze::Helper::Bench

  log = []
  def log.info(arg); push(arg); end
  Ramaze::Log.loggers = [log]

  it 'logs running time' do
    result = bench{ sleep 0.1; 'result' }
    result.should == 'result'
    log.size.should == 1
    # output between ruby 1.8 and 1.9 differs...
    log.pop.should =~ %r!^Bench #{__FILE__}:#{__LINE__ - 4}:.* \d\.\d+$!
  end
end
