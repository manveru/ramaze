require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'amrita2'
require 'examples/templates/template_amrita2'

describe 'Template Amrita2' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Amrita2' )
end
