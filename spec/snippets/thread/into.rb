#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCThreadIntoController < Ramaze::Controller
  map :/

  def hello
    Thread.into('goodbye') do |str|
      "#{Ramaze::Action.current.name}, #{str}"
    end.value
  end
end

describe 'Thread.into' do
  ramaze
  it 'should provide access to thread vars' do
    get('/hello').body.should == 'hello, goodbye'
  end
end