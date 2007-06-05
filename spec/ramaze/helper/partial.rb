#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCPartialHelperController < Ramaze::Controller
  map '/'
  helper :partial
  template_root(File.dirname(__FILE__)/:template)

  def index
    '<http><head><title>#{render_partial("/title")}</title></head></http>'
  end

  def title
    "Title"
  end

  def composed
    @here = 'there'
    'From Action | ' +
    render_template("partial.xhtml")
  end
end

describe "PartialHelper" do
  before :all do
    ramaze
  end

  it "should render partials" do
    get('/').body.should == '<http><head><title>Title</title></head></http>'
  end

  it 'should be able to render a template in the current scope' do
    get('/composed').body.should == 'From Action | From Partial there'
  end
end
