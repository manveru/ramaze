#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'bluecloth'
require 'ramaze'

require 'src/model'

include Ramaze
require 'src/controller'
require 'src/element'

Global.setup do |g|
  g.template_root = 'template'
  g.mapping = {
    '/'       => MainController,
  }
end

start
