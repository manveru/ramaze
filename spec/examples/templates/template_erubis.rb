require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'erubis'
require 'examples/templates/template_erubis'

describe 'Template Erubis' do
  behaves_like :template_spec
  spec_template 'Erubis'
end
