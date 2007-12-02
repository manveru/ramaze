require 'spec/helper'
testcase_requires 'haml'

require 'examples/css'

describe 'CSSController' do
  ramaze

  def req(path) r = get(path); [r.content_type, r.body] end

  it 'should cache generated css' do
    lambda{ req('/css/style.css') }.should_not change{ req('/css/style.css') }
  end
end