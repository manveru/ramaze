require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'remarkably/engines/html'
require 'examples/templates/template_remarkably'

describe 'Template Remarkably' do
  behaves_like :template_spec
  spec_template 'Remarkably'
end
