require 'spec/helper'

Ramaze.options.app.root = '/'

class SpecControllerInheritedMain < Ramaze::Controller
  Ramaze.node('/')
  def index
    @ngr = "Main is nagoro"
    "<p>#{@ngr}</p>"
  end
end

class SpecControllerInheritedOther < Ramaze::Controller
  Ramaze.node('/other').provide(:html => :haml)
  def index; "%p Other is haml"; end
end

class SpecControllerInheritedAnother < SpecControllerInheritedOther
  Ramaze.node('/another')
  def index; "%p Another is haml. Inherit from Other"; end
end

class SpecControllerInheritedYetAnother < SpecControllerInheritedAnother
  Ramaze.node('/yet_another').provide(:html => :maruku)
  def index; "Yet Another is Maruku. Inherited but overriden"; end
end

describe 'Ramaze::Controller#self.inherited' do
  behaves_like :mock

  should 'default renders nagoro' do
    get('/').body.should == "<p>Main is nagoro</p>"
  end

  should 'be able to render provided format' do
    get('/other').body.should == "<p>Other is haml</p>\n"
  end

  should "inherit provide from parent controller" do
    get('/another').body.should ==
      "<p>Another is haml. Inherit from Other</p>\n"
  end

  should "be able to override inherited provide" do
    get('/yet_another').body.should ==
      "<p>Yet Another is Maruku. Inherited but overriden</p>"
  end
end
