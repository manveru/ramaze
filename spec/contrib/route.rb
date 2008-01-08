require 'spec/helper'

Ramaze.contrib :route

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

  def sum(a, b)
    a.to_i + b.to_i
  end
end

describe 'Route' do
  behaves_like 'http'
  ramaze
  @route = Ramaze::Contrib::Route

  it 'should take custom lambda routers' do
    @route['string'] = lambda {|path, req| path if path =~ %r!^/string! }
    @route['string'].class.should == Proc

    @route['calc sum'] = lambda do |path, req|
      if req[:do_calc]
        lval, rval = req[:a, :b]
        rval = rval.to_i * 10
        "/sum/#{lval}/#{rval}"
      end
    end
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

  it 'should use lambda routers' do
    r = get('/string/abc')
    r.status.should == 200
    r.body.should == 'String: abc'

    r = get('/', 'do_calc=1&a=2&b=6')
    r.status.should == 200
    r.body.should == '62'
  end
end
