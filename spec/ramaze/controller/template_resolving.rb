#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class MainController < Ramaze::Controller
  template_root "#{File.expand_path(File.dirname(__FILE__))}/template"

  def greet(type, message = "Message")
    @greet = "#{type} : #{message}"
  end

  def list
    @obj = Ramaze::Action.current.method
  end
  alias_method :index, :list
  template :index, 'list'

end

class OtherController < MainController
  template_root "#{File.expand_path(File.dirname(__FILE__))}/template/other"

  def greet__mom(message = "Moms are cool!")
    greet('Mom', message)
  end
  template :greet__mom, MainController, :greet

  def greet__other(one, two)
    @greet = "Other"
  end
  template :greet__other, 'greet/other'

  def partial_stuff
    render_partial('/greet/the/world', :foo => :bar)
  end
end

class Ramaze::Controller
  private

  def render_partial(url, options = {})
    body = Ramaze::Controller.handle(url)
    body
  end
end

describe "Testing Template overriding" do
  ramaze(:mapping => {'/' => MainController, '/other' => OtherController})

  it "simple request to greet" do
    get('/greet/asdf').body.should == '<html>asdf : Message</html>'
  end

  it "referencing template from MainController" do
    get('/other/greet/mom').body.should == '<html>Mom : Moms are cool!</html>'
  end

  it "should accept template overrides with same name as controller" do
    get('/other/greet/other/one/two').body.should == '<html>Other: Other</html>'
  end

  it "setting template for non-existant :index action should not arbitrary parameters" do
    get('/list').body.should == '<html>list</html>'

    response = get('/non_existant_method')
    response.status.should == 404
    response.body.should =~ %r(No Action found for `/non_existant_method' on MainController)
  end

end

describe "render_partial" do
  it 'greet' do
    result = get('/other/partial_stuff')
    result.body.should == '<html>the : world</html>'
  end
end
