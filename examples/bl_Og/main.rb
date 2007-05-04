$DBG = true

require 'ramaze'
require 'og'

include Ramaze

require 'src/model'
require 'src/view'
require 'src/controller'

Og.setup :evolve_schema => :full

Entry.create "Blog created", "Exiting news today, this blog was created!" if
  Entry.count == 0

start
