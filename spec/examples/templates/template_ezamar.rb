require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'ezamar'
require 'examples/templates/template_ezamar'

describe 'Template Ezamar' do
  behaves_like :template_spec
  spec_template 'Ezamar'
end
