#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

require 'src/model'

include Ramaze
require 'src/controller'
require 'src/element'

Global.template_root = 'template'
Global.mapping = {
  '/'       => MainController,
  '/entry'  => EntryController,
}
