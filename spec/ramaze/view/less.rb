#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'less'

Ramaze::App.options.views = 'less'

class SpecLess < Ramaze::Controller
  map '/'
  provide :css, :Less

  def style
    <<-LESS
@dark: #110011;
.outline { border: 1px solid black }

.article {
  a { text-decoration: none }
  p { color: @dark }
  .outline;
}
    LESS
  end
end

describe Ramaze::View::Less do
  behaves_like :rack_test

  def cmp(actually, expected)
    actually.strip.split("\n").sort.
      should == expected.strip.split("\n").sort
  end

  should 'render inline' do
    got = get('/style.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'

    cmp(got.body, <<-CSS)
.outline { border: 1px solid black; }
.article a { text-decoration: none; }
.article p { color: #110011; }
.article { border: 1px solid black; }
    CSS
  end

  should 'render from file' do
    got = get('/file.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'

    cmp(got.body, <<-CSS)
.outline { border: 1px solid black; }
.article a { text-decoration: none; }
.article p { color: #110011; }
.article { border: 1px solid black; }
    CSS
  end
end
