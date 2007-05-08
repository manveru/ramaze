#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper/layout'

layout = {
  'ramaze' => {
    '.'         => '*',
    'adapter'   => '*',
    'helper'    => '*',
    'inform'    => '*',
    'request'   => '*',
    'store'     => '*',
    'template'  => '*',
    },
  'examples' => {
    '.' => '*',
    'templates' => '*'
  }
}

manually_add = %w[ramaze/template]
manually_add.map!{|ma| File.expand_path("spec/#{ma}.rb") }

layout = SpecLayout.new(File.dirname(__FILE__), layout)
layout.gather
layout.clean
layout.files += manually_add
layout.run
