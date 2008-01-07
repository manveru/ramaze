#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'
require 'ramaze/spec/helper'

require __DIR__/'..'/'start'

describe MainController do
  behaves_like 'http', 'xpath'
  ramaze :template_root => __DIR__/'../view',
         :public_root => __DIR__/'../public'

  it 'should show start page' do
    got = get('/')
    got.status.should == 200
    got.at_xpath('//title').text.strip.should ==
      MainController.new.index
  end

  it 'should show /notemplate' do
    got = get('/notemplate')
    got.status.should == 200
    got.at_xpath('//body').text.strip.should ==
      MainController.new.notemplate
  end
end
