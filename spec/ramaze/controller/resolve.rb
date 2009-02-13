#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

Ramaze.options.app.root = '/'
Ramaze.options.app.view = __DIR__(:view)

class MainController < Ramaze::Controller
  map '/'
  engine :Nagoro

  define_method('file.ext'){ 'file.ext' }
  define_method('css__file.css'){ 'file.css' }
  define_method('path__to__js__file.js'){ 'file.js' }
  define_method('other__greet__other'){ @greet = 'hi' }
end

describe 'Controller resolving' do
  behaves_like :mock

  it 'should work with .' do
    get('/file.ext').body.should == 'file.ext'
  end

  it 'should work with /' do
    get('/css/file.css').body.should == 'file.css'
    get('/path/to/js/file.js').body.should == 'file.js'
  end

  it 'should find templates' do
    get('/other/greet/other').body.should == '<html>Other: hi</html>'
  end
end
