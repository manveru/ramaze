require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'haml'
require 'examples/templates/template_haml'

describe 'Template Haml' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Haml' )
end
