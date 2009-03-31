require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'liquid'
require 'examples/templates/template_liquid'

describe 'Template Liquid' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Liquid' )
end
