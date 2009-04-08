require 'spec/helper'
require 'ramaze/spec/helper/template_examples'

require 'examples/templates/template_nagoro'

describe 'Template Nagoro' do |describe|
  ::Ramaze::Spec::Examples::Templates.tests( describe, 'Nagoro' )
end

