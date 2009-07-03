#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)

class LayoutHelperOne < Ramaze::Controller
  map '/one'
  set_layout 'default'

  def laid_out1; end
  def laid_out2; end
  def laid_out3; end
end

class LayoutHelperTwo < Ramaze::Controller
  map '/two'
  set_layout 'default' => [:laid_out1, :laid_out2]

  def laid_out1; end
  def laid_out2; end

  def not_laid_out; end
end

class LayoutHelper < Ramaze::Controller
  map '/three'
  set_layout_except 'default' => [:not_laid_out1, :not_laid_out2]

  def laid_out1; end
  def laid_out2; end

  def not_laid_out1; end
  def not_laid_out2; end
end


describe Ramaze::Helper::Layout do
  behaves_like :rack_test

  it 'lays out all actions' do
    get '/one/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/one/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/one/laid_out3'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
  end

  it 'lays out only a whitelist of actions' do
    get '/two/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/two/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/two/not_laid_out'
    last_response.status.should == 200
    last_response.body.should.not.match /laid out/
  end

  it 'lays out all actions except a blacklist' do
    get '/three/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/three/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
    get '/three/not_laid_out1'
    last_response.status.should == 200
    last_response.body.should.not.match /laid out/
    get '/three/not_laid_out2'
    last_response.status.should == 200
    last_response.body.should.not.match /laid out/
  end

end
