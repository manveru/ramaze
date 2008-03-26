#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAdapterController < Ramaze::Controller
  map '/'

  def index
    "The index"
  end
end

$output = StringIO.new
Ramaze::Log.loggers << Ramaze::Informer.new($output)

describe "Adapter" do
  ramaze ramaze_options
  behaves_like "http"

  it 'should do a simple request' do
    get('/').body.should == 'The index'
  end

  it 'should measure request processing time' do
    Ramaze::Global.benchmarking = true
    $output.string = ""
    get('/')
    $output.string.should =~ /request took/
    Ramaze::Global.benchmarking = false
  end

  it 'should not measure request processing time' do
    Ramaze::Global.benchmarking = false
    $output.string = ""
    get('/')
    $output.string.should.not =~ /request took/
  end
end
