if caller
  snippet = caller.grep(%r!spec/snippets/!).first.split(':').first
  require File.expand_path(snippet).gsub('/spec/', '/lib/ramaze/')
end

require 'lib/vendor/bacon'
Bacon.extend Bacon::TestUnitOutput
Bacon.summary_on_exit
