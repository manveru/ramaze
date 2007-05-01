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
  'examples' => '*'
}

layout = SpecLayout.new(File.dirname(__FILE__), layout)
layout.run
