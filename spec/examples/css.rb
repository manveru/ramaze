require File.expand_path('../../../spec/helper', __FILE__)
spec_require 'haml'
require File.expand_path('../../../examples/misc/css', __FILE__)

describe 'CSSController' do
  behaves_like :rack_test

  def req(path) r = get(path); [r.content_type, r.body] end

  it 'should cache generated css' do
    lambda{ req('/css/style.css') }.
      should.not.change{ req('/css/style.css') }
  end
end
