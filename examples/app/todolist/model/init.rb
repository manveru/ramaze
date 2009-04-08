module TodoList
  # yeah, we're lazy
  Sequel::Model.plugin(:schema)

  # Uncomment the line for the DB you want to use.

  # Sqlite In memory, fastest, but cannot persist over restarts.
  DB = Sequel.sqlite

  # Sqlite on disk
  # DB = Sequel.sqlite(__DIR__('../todolist.sqlite'))
end

require 'model/task'
