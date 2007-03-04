#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  def index
    self.class.name
  end
end

context "Error" do
  context "in dispatcher" do
    ramaze :mapping => {'/' => TCErrorController }, :error_page => true

    specify "your illegal stuff" do
      lambda{ get('/def/illegal') }.should_raise RuntimeError, /Net::HTTPNotFound/
    end
  end

  context "no controller" do
    Ramaze::Global.mapping = {}

    specify "your illegal stuff" do
      lambda{ get('/def/illegal') }.should_raise RuntimeError, /Net::HTTPNotFound/
    end
  end
end
