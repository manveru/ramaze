require 'ramaze'
require 'uv'

Ramaze::Inform.debug "Initializing UltraViolet..."

Uv.copy_files "xhtml", __DIR__/"public"
Uv.init_syntaxes

UV_PRIORITY_NAMES = %w[ ruby plain_text html css javascript yaml ]

STYLE = 'iplastic'

Ramaze::Inform.debug "done."

Ramaze.contrib :route

require 'src/model'
require 'src/controller'

Ramaze.start :adapter => :mongrel
