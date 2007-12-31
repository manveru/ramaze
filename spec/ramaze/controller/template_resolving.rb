#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class MainController < Ramaze::Controller

  def greet(type, message = "Message")
    @greet = "#{type} : #{message}"
  end

  def list
    @obj = Ramaze::Action.current.method
  end

  alias_method :index, :list
  template :index, 'list'
  template :non_existant_method, :list

end

class OtherController < MainController

  def greet__mom(message = "Moms are cool!")
    greet('Mom', message)
  end
  template :greet__mom, MainController, :greet

  def greet__other
    @greet = "Other"
  end
  template :greet__other, :blah

  def greet__another
    @greet = "Another"
  end
  template :greet__another, :greet__other

  def greet__last
    @greet = 'Last'
  end
  template :greet__last, 'greet/other'

end

describe "Testing Template overriding" do
  behaves_like 'http'
  ramaze

  it "simple request to greet" do
    get('/greet/asdf').body.should == '<html>asdf : Message</html>'
  end

  it "referencing template from MainController" do
    get('/other/greet/mom').body.should == '<html>Mom : Moms are cool!</html>'
  end

  it "should treat template overrides as possible alternatives (only use if found)" do
    get('/other/greet/other').body.should == '<html>Other: Other</html>'
  end

  it "should accept template overrides given as symbols" do
    get('/other/greet/another').body.should == '<html>Other: Another</html>'
  end

  it "should accept template overrides given as strings" do
    get('/other/greet/last').body.should == '<html>Other: Last</html>'
  end

  it "should set template for aliased :index action" do
    get('/list').body.should == '<html>list</html>'
    get('/index').body.should == '<html>index</html>'
  end

  it "should use template overrides for non-existant actions" do
    get('/non_existant_method').body.should == '<html></html>'
  end
end
