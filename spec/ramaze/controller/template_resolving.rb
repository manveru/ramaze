#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

Ramaze.options.app.root = '/'
Ramaze.options.app.view = __DIR__(:view)

class MainController < Ramaze::Controller
  map '/'
  view_root(__DIR__(:view))
  engine :Nagoro

  def greet(type, message = "Message")
    @greet = "#{type} : #{message}"
  end

  def list
    @obj = Ramaze::Current.action.method
  end

  alias_method :index, :list
  alias_view :index, :list
  alias_view :non_existant_method, :list
end

class OtherController < MainController
  map '/other'

  def greet__mom(message = "Moms are cool!")
    greet('Mom', message)
  end
  alias_view :greet__mom, :greet, MainController

  def greet__other
    @greet = "Other"
  end
  alias_view :greet__other, :blah

  def greet__another
    @greet = "Another"
  end
  alias_view :greet__another, :greet__other

  def greet__last
    @greet = 'Last'
  end
  alias_view :greet__last, 'greet__other'
end

class AnotherController < MainController
  map '/another'

  def greet_absolute(type, message = "Message")
    @greet = "#{type} : #{message}"
  end
  alias_view :greet_absolute, 'greet'

  def greet_relative(type, message = "Message")
    @greet = "#{type} : #{message}"
  end
  alias_view :greet_relative, 'greet'

  def greet_controller_action(type, message = "Message")
    @greet = "#{type} : #{message}"
  end
  alias_view :greet_controller_action, :greet, MainController
end

describe "Testing Template overriding" do
  behaves_like :mock

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

  it "should allow template overrides to be specified by absolute path" do
    get('/another/greet_absolute/asdf').body.should == '<html>asdf : Message</html>'
  end

  it "should allow template overrides to be specified by relative path" do
    get('/another/greet_relative/asdf').body.should == '<html>asdf : Message</html>'
  end

  it "should allow template overrides to be specified by named controller and action" do
    get('/another/greet_controller_action/asdf').body.should == '<html>asdf : Message</html>'
  end
end
