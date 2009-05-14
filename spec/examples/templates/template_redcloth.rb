require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'redcloth'
spec_require 'examples/templates/template_redcloth'

describe 'Template RedCloth' do
  behaves_like :template_spec
  spec_template 'RedCloth'
end
