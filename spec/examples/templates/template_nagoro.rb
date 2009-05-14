require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'nagoro'
require 'examples/templates/template_nagoro'

describe 'Template Nagoro' do
  behaves_like :template_spec
  spec_template 'Nagoro'
end
