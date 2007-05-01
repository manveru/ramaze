#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/tool/localize'
require 'ramaze/trinity/session'
#require 'ramaze/inform'

Ramaze::Tool::Localize.trait :enable    => true,
                             :file      => 'spec/ramaze/conf/locale_%s.yaml'.freeze,
                             :languages => %w[en de]

class TCLocalize < Ramaze::Controller
  trait :map => '/'

  def hello lang = 'en'
    session[:LOCALE] = lang
    '[[hello]]'
  end

  def advanced lang = 'en'
    session[:LOCALE] = lang
    '[[this]] [[is]] [[a]] [[test]]'
  end
end

describe "Localize" do
  ramaze

  it "hello world" do
    get('/hello').should == 'Hello, World!'
    get('/hello/de').should == 'Hallo, Welt!'
  end

  it "advanced" do
    get('/advanced').should == 'this is a test'
    get('/advanced/de').should == 'Das ist ein Test'
  end
end
