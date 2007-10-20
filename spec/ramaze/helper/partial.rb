#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCPartialHelperController < Ramaze::Controller
  map '/'
  helper :partial

  def index
    '<html><head><title>#{render_partial("/title")}</title></head></html>'
  end

  def title
    "Title"
  end

  def composed
    @here = 'there'
    'From Action | ' +
    render_template("partial.xhtml")
  end

  def recursive
    @n = 1
  end
end

describe "PartialHelper" do
  before :all do
    ramaze
  end

  it "should render partials" do
    get('/').body.should == '<html><head><title>Title</title></head></html>'
  end

  it 'should be able to render a template in the current scope' do
    get('/composed').body.should == 'From Action | From Partial there'
  end

  it 'should work recursively' do
    get('/recursive').body.gsub(/\s/, '').should ==
      '<ul><li>1</li><ul><li>2</li><li>2</li></ul><li>1</li></ul>'
  end
end
