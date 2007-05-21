#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCControllerController < Ramaze::Controller
  map '/'
  template_root 'spec/ramaze/template/ezamar'

  def index
    @text = "World"
  end

  def sum first, second
    @num1, @num2 = first.to_i, second.to_i
  end

  def some__long__action
  end

  def another__long__action
  end

  private

  def test_private
  end
end

describe "Controller" do
  ramaze :error_page => false, :adapter => :mongrel

  describe 'dry specs' do
    describe 'pattern_for' do
      hash = {
        '/' => [
          ["/", 'index', []]
        ],

        '/foo' => [
          ["/foo", 'index',[]],
          ['/',    'foo',  []],
          ["/",    'index', ["foo"]],
        ],

        '/foo/bar' => [
          ["/foo__bar", "index",    []],
          ["/foo/bar",  "index",    []],

          ["/foo",      "bar",      []],
          ["/foo",      "index",    ["bar"]],

          ["/",         "foo__bar", []],
          ["/",         "foo",      ["bar"]],
          ["/",         "index",    ["foo", "bar"]],
        ],

        '/foo/bar/baz' => [

          ['/foo__bar__baz', 'index',         []],
          ['/foo/bar/baz',   'index',         []],

          ['/foo__bar',      'baz',           []],
          ['/foo__bar',      'index',         ['baz']],

          ['/foo/bar',       'baz',           []],
          ['/foo/bar',       'index',         ['baz']],

          ['/foo',           'bar__baz',      []],
          ['/foo',           'bar',           ['baz']],
          ['/foo',           'index',         ['bar', 'baz']],

          ['/',              'foo__bar__baz', []],
          ['/',              'foo__bar',      ['baz']],
          ['/',              'foo',           ['bar', 'baz']],
          ['/',              'index',         ['foo', 'bar', 'baz']],
        ],

        '/foo/bar/baz/oof' => [
          ['/foo__bar__baz__oof', 'index',               []],

          ['/foo/bar/baz/oof',    'index',               []],

          ['/foo__bar__baz',      'oof',                 []],
          ['/foo__bar__baz',      'index',               ['oof']],

          ['/foo/bar/baz',        'oof',                 []],
          ['/foo/bar/baz',        'index',               ['oof']],

          ['/foo__bar',           'baz__oof',            []],
          ['/foo__bar',           'baz',                 ['oof']],
          ['/foo__bar',           'index',               ['baz', 'oof']],

          ['/foo/bar',            'baz__oof',            []],
          ['/foo/bar',            'baz',                 ['oof']],
          ['/foo/bar',            'index',               ['baz', 'oof']],

          ['/foo',                'bar__baz__oof',       []],
          ['/foo',                'bar__baz',            ['oof']],
          ['/foo',                'bar',                 ['baz', 'oof']],
          ['/foo',                'index',               ['bar', 'baz', 'oof']],

          ['/',                   'foo__bar__baz__oof',  []],
          ['/',                   'foo__bar__baz',       ['oof']],
          ['/',                   'foo__bar',            ['baz', 'oof']],
          ['/',                   'foo',                 ['bar', 'baz', 'oof']],
          ['/',                   'index',               ['foo', 'bar', 'baz', 'oof']],
        ]
      }

      hash.each do |path, correct|
        describe path do
          patterns = Ramaze::Controller.pattern_for(path)

          describe path do
            it(path){ patterns.should == correct }
            correct.zip(patterns).each do |(cc,cm,cp),(pc,pm,pp)|
              {cc,pc,cm,pm,cp,pp}.each{|a,b| a.should == b}
            end
          end
        end
      end
    end
  end

  describe 'resolve' do
    def resolve(path)
      TCControllerController.resolve(path)
    end

    def values(*url)
      resolve(*url).last.values_at(:method, :params, :template)
    end

    it '/' do
      values('/').should ==
        ['index', [], 'spec/ramaze/template/ezamar/index.zmr']
    end

    it '/sum/1/2' do
      values('/sum/1/2').should ==
        ['sum', ['1', '2'],'spec/ramaze/template/ezamar/sum.zmr']
    end

    it '/another/long/action' do
      values('/another/long/action').should ==
        ['another__long__action', [], 'spec/ramaze/template/ezamar/another/long/action.zmr']
    end
    it '/some/long/action' do
      values('/some/long/action').should ==
        ['some__long__action', [], 'spec/ramaze/template/ezamar/some__long__action.zmr']
    end
  end

  it "simple request to index" do
    get('/').body.should == 'Hello, World!'
  end

  it "summing two values" do
    get('/sum/1/2').body.should == '3'
  end

  it "double underscore in templates" do
    get('/some/long/action').body.should == 'some long action'
    get('/another/long/action').body.should == 'another long action'
  end

  describe "should not respond to private methods" do
    TCControllerController.private_methods.sort.each do |action|
      next if action =~ /\?$/ or action == '`'
      it action do
        path = "/#{action}"
        response = get(path)
        response.body.should =~ %r(No Action found for `#{path}' on TCControllerControlle)
        response.status.should == 404
      end
    end
  end
end
