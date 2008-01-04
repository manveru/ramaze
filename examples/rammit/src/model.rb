require 'sequel'

DB = Sequel.sqlite

class User < Sequel::Model(:user)
  set_schema do
    primary_key :id

    text :nick
    text :password
    text :email
    time :created
  end
end

class Page < Sequel::Model(:page)
  set_schema do
    primary_key :id

    text :id
  end
end

[ User, Page ].each do |model|
  model.create_table! unless model.table_exists?
end
