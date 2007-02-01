#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCAuthHelperController < Template::Ramaze
  helper :auth

  def session_inspect
    session.inspect
  end

  def secured
    "Secret content"
  end
  pre :secured, :logged_in?
end

context "StackHelper" do
  ramaze(:mapping => {'/' => TCAuthHelperController})

  ctx = Context.new '/session_inspect'

  specify "checking security" do
    ctx.get('/secured').should == ''
    ctx.get('/secured').should == ''
    ctx.post('/login', :username => 'manveru', :password => 'password').should == 'Secret content'
    ctx.get('/secured').should == 'Secret content'
    ctx.get('/secured').should == 'Secret content'
  end
end
