require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'liquid'
require 'examples/templates/template_liquid'

describe 'Template Liquid' do
  behaves_like :template_spec
  spec_template 'Liquid'
end
