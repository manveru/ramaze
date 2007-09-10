require 'spec/helper'

require 'ramaze/contrib'

class MainController < Ramaze::Controller
  def integer(num)
    "Integer: #{num}"
  end

  def float(flt)
    "Float: #{flt}"
  end
end

describe 'Route' do
  before :all do
    Ramaze.contrib :route
    Ramaze::Controller::FILTER.replace [:cached, :routed, :default]
    ramaze
  end

  it 'should be possible to define routes' do
    Ramaze::Route[%r!^/(\d+\.\d+)!] = "/float/%.3f"
    Ramaze::Route[%r!^/(\d+\.\d+)!].should == "/float/%.3f"

    Ramaze::Route[%r!^/(\d+)!] = "/integer/%d"
    Ramaze::Route[%r!^/(\d+)!].should == "/integer/%d"
  end

  it 'should be used - /integer' do
    r = get('/123')
    r.status.should == 200
    r.body.should == 'Integer: 123'
  end

  it 'should be used - /float' do
    r = get('/123.123')
    r.status.should == 200
    r.body.should == 'Float: 123.123'
  end
end
