require 'spec/helper'

class MainController < Ramaze::Controller
  def float(flt)
    "Float: #{flt}"
  end

  def string(str)
    "String: #{str}"
  end

  def price(p)
    "Price: \$#{p}"
  end
end

describe 'Route' do
  before :all do
    Ramaze.contrib :route
    ramaze
    @route = Ramaze::Contrib::Route
  end

  it 'should be possible to define routes' do
    @route[%r!^/(\d+\.\d{2})$!] = "/price/%.2f"
    @route[%r!^/(\d+\.\d{2})$!].should == "/price/%.2f"

    @route[%r!^/(\d+\.\d+)!] = "/float/%.3f"
    @route[%r!^/(\d+\.\d+)!].should == "/float/%.3f"

    @route[%r!^/(\w+)!] = "/string/%s"
    @route[%r!^/(\w+)!].should == "/string/%s"
  end

  it 'should be used - /float' do
    r = get('/123.123')
    r.status.should == 200
    r.body.should == 'Float: 123.123'
  end

  it 'should be used - /string' do
    r = get('/foo')
    r.status.should == 200
    r.body.should == 'String: foo'
  end

  it 'should use %.3f' do
    r = get('/123.123456')
    r.status.should == 200
    r.body.should == 'Float: 123.123'
  end

  it 'should resolve in the order added' do
    r = get('/12.84')
    r.status.should == 200
    r.body.should == 'Price: $12.84'
  end
end
