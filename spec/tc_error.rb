#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCErrorController < Template::Ezamar
  def index
    self.class.name
  end
end

context "Error" do
  context "in dispatcher" do
    ramaze :mapping => {'/' => TCErrorController}, :error_page => true

    specify "wrong parameter" do
      get('/').should == 'TCErrorController'
      get('/1').should =~ /NoAction/
    end
  end
end
