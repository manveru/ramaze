#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rubygems'
require_gem 'facets', '= 1.4.5'
require '/home/manveru/prog/projects/nitroproject/glycerin'
require 'og'

class Comment
  attr_accessor :text, String
  attr_accessor :time, Time
  attr_accessor :author_name, String
  attr_accessor :author_email, String
end

class Entry
  attr_accessor :title, String
  attr_accessor :text, String
  attr_accessor :time, Time
  has_many Comment
end

unless defined? Entry.ogmanager
  Og.setup
end
