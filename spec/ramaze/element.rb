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

context "Element" do
  ramaze(:mapping => {'/' => TCElementController})

  specify "simple request" do
    get('/').should == "The index"
  end

  specify "with element" do
    get('/elementy').should == "<wrap> The index </wrap>"
  end

  specify "nested element" do
    get('/nested').should == "<wrap>  some stuff  <wrap> The index </wrap>  more stuff  </wrap>"
  end

  specify "with_params" do
    get('/with_params/one/two').should == {'@one' => 'two'}.inspect
  end

  specify "little" do
    get('/little').should == 'little'
  end

  specify "little params" do
    get('/little_params/one/eins').should == {'@one' => 'eins'}.inspect
  end

  specify "templating" do
    get('/templating/10').should == (1..10).to_a.join(', ')
  end
end
