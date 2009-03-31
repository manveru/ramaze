require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'remarkably/engines/html'
require 'examples/templates/template_remarkably'

describe 'Template Remarkably' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Remarkably' )
end
