require 'sequel'

module Blog
  DB = Sequel.sqlite("#{__DIR__}/../blog.db")
  # DB = Sequel.connect("sqlite:///#{__DIR__}/../blog.db")
end

require 'model/tag'
require 'model/entry'
require 'model/comment'
