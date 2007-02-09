#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

require 'src/controller/main'
require 'src/element/page'
require 'src/model'

# mode selects the config-file.
# benchmark | debug | stage | live | silent
mode = 'debug'

Global.setup YAML.load_file("conf/#{mode}.yaml")

start
