require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

require 'examples/templates/template_ezamar'

describe 'Template Ezamar' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Ezamar' )
end
