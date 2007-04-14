#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

dir  = File.join(File.expand_path(File.dirname(__FILE__)), 'snippets')
glob = File.join(dir, '**', '*.rb')

Dir[glob].each do |snippet|
  require(snippet)
end
