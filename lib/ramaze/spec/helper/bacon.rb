require 'bacon'

dir = File.dirname(__FILE__)
require File.join(File.dirname(__FILE__), 'pretty_output')

Bacon.extend Bacon::PrettyOutput
Bacon.summary_on_exit
