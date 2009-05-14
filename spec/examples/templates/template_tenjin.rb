require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'tenjin'
require 'examples/templates/template_tenjin'

describe 'Template Tenjin' do
  behaves_like :template_spec
  spec_template 'Tenjin'
end
