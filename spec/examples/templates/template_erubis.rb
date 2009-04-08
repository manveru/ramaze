require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

spec_require 'erubis'
require 'examples/templates/template_erubis'

describe 'Template Erubis' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Erubis' )
end
