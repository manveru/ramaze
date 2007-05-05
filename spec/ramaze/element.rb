#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCElementController < Ramaze::Controller
  trait :engine => Ramaze::Template::Ezamar

  def index
    "The index"
  end

  def elementy
    "<Page>#{index}</Page>"
  end

  def nested
    "<Page> some stuff <Page>#{index}</Page> more stuff </Page>"
  end

  def with_params(*params)
    hash = Hash[*params.flatten].map{|k,v| %{#{k}="#{v}"}}.join(' ')
    %{<PageWithParams #{hash}></PageWithParams>}
  end

  def little
    %{<PageLittle />}
  end

  def little_params(*params)
    hash = Hash[*params.flatten].map{|k,v| %{#{k}="#{v}"}}.join(' ')
    %{<PageLittleWithParams #{hash} />}
  end

  def templating(times)
    %{<PageWithTemplating times="#{times}" />}
  end
end

class Page < Ezamar::Element
  def render
    %{ <wrap> #{content} </wrap> }
  end
end


class PageWithParams < Ezamar::Element
  def render
    ivs = (instance_variables - ['@content'])
    ivs.inject({}){|s,v| s.merge(v => instance_variable_get(v)) }.inspect
  end
end

class PageLittle < Ezamar::Element
  def render
    "little"
  end
end

class PageLittleWithParams < Ezamar::Element
  def render
    ivs = (instance_variables - ['@content'])
    ivs.inject({}){|s,v| s.merge(v => instance_variable_get(v)) }.inspect
  end
end

class PageWithTemplating < Ezamar::Element
  def render
    (1..@times).to_a.join(', ')
  end
end

describe "Element" do
  ramaze(:mapping => {'/' => TCElementController})

  it "simple request" do
    get('/').body.should == "The index"
  end

  it "with element" do
    get('/elementy').body.should == "<wrap> The index </wrap>"
  end

  it "nested element" do
    get('/nested').body.should == "<wrap>  some stuff  <wrap> The index </wrap>  more stuff  </wrap>"
  end

  it "with_params" do
    get('/with_params/one/two').body.should == {'@one' => 'two'}.inspect
  end

  it "little" do
    get('/little').body.should == 'little'
  end

  it "little params" do
    get('/little_params/one/eins').body.should == {'@one' => 'eins'}.inspect
  end

  it "templating" do
    get('/templating/10').body.should == (1..10).to_a.join(', ')
  end
end
