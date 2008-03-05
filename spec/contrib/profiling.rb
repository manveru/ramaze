require 'spec/helper'

Ramaze.contrib :profiling

class MainController < Ramaze::Controller
  def index
    100.times {"h" + "e" + "l" + "l" + "o"}
  end
end

output = StringIO.new
Ramaze::Inform.loggers << Ramaze::Informer.new(output)

describe 'Profiling' do
  behaves_like "http"
  ramaze

  it "should profile" do
    get('/')
    output.string.should =~ /Thread ID:\s\d+/
    output.string.should =~ /Total:/
    output.string.should =~ /self\s+total\s+self\s+wait\s+child\s+call/
  end
end
