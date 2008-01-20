require 'tmpdir'

require 'ramaze'
require 'sequel'
require 'uv'

Ramaze::Inform.debug "Initializing UltraViolet..."

Uv.copy_files "xhtml", __DIR__/"public"
Uv.init_syntaxes

UV_PRIORITY_NAMES = %w[ ruby plain_text html css javascript yaml diff ]

STYLE = 'iplastic'

Ramaze::Inform.debug "done."
Ramaze.contrib :route

DB = Sequel.sqlite

require 'model/paste'
require 'controller/paste'

Ramaze.start
