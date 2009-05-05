require 'sequel'
require 'sequel/extensions/inflector'

module Blog
  DB = Sequel.sqlite("#{__DIR__}/../blog.db")
  # DB = Sequel.connect("sqlite:///#{__DIR__}/../blog.db")
end

Sequel::Model.plugin :validation_class_methods
Sequel::Model.plugin :schema
Sequel::Model.plugin :hook_class_methods

require 'model/tag'
require 'model/entry'
require 'model/comment'
