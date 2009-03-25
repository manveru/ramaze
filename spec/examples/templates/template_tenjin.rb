require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'tenjin'
require 'examples/templates/template_tenjin'

describe 'Template Tenjin' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Tenjin' )
end
