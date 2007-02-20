#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/store/yaml'

Entry = Ramaze::Store::YAML.new :entry

if Entry.empty?
  entry = Entry.new
  entry.time = Time.now
  entry.title = 'Nothing special'
  entry.text = 'even less special'
  entry.save
end
