require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'haml'
require 'examples/templates/template_haml'

describe 'Template Haml' do
  behaves_like :template_spec
  spec_template 'Haml'
end
