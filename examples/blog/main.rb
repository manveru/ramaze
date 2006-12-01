require 'ramaze'

require 'src/model'

include Ramaze
require 'src/controller'

Global.template_root = 'template'
Global.mapping = {
  '/'       => MainController,
  '/entry'  => EntryController,
}
