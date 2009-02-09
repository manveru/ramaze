#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class SpecHelperFlash < Ramaze::Controller
  map :/
  helper :flash
  trait :flashbox => "%key : %value"

  def box
    flashbox
  end

  def populate_one
    flash[:one] = 'for starters'
  end

  def populate_two
    flash[:one] = 'this one'
    flash[:two] = 'and this'
  end
end

describe Ramaze::Helper::Flash do
  behaves_like :session

  it 'displays a flashbox with one item' do
    session do |mock|
      mock.get('/populate_one')
      got = mock.get('/box')
      got.status.should == 200
      got.body.should == 'one : for starters'
    end
  end

  it 'displays a flashbox with two items' do
    session do |mock|
      mock.get('/populate_two')
      got = mock.get('/box')
      got.status.should == 200
      got.body.split("\n").sort.should == ['one : this one', 'two : and this']
    end
  end
end
