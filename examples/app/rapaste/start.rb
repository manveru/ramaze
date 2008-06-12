require 'rubygems'
require 'tmpdir'

require 'ramaze'
require 'sequel'
require 'uv'

Ramaze::Log.debug "Initializing UltraViolet..."

Uv.copy_files "xhtml", __DIR__/"public"
Uv.init_syntaxes

UV_PRIORITY_NAMES = %w[ ruby plain_text html css javascript yaml diff ]

STYLE = 'iplastic'

Ramaze::Log.debug "done."

DB = Sequel.connect("sqlite://#{__DIR__}/rapaste.sqlite")

require 'model/paste'
require 'controller/paste'

Ramaze.start
