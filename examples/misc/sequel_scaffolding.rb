require 'rubygems'
require 'ramaze'
require 'sequel'
require 'scaffolding_extensions'

# More information on Scaffolding Extensions here: http://scaffolding-ext.rubyforge.org/

DB = Sequel.sqlite

# Sequel::Model doesn't support schema creation by default
# So we have to load it as a plugin
Sequel::Model.plugin :schema

class User < Sequel::Model(:user)
  set_schema do
    primary_key :id
    varchar :name
    text :description
  end

  create_table unless table_exists?
  
  # Add a couple of users to our database
  create(:name => 'manveru', :description => 'The first user!')
  create(:name => 'injekt', :description => 'Just another user')
end

ScaffoldingExtensions.all_models = [User]

class UserController < Ramaze::Controller
  map '/user'
  scaffold_all_models :only => [User]
end

class MainController < Ramaze::Controller
  def index
    %{Scaffolding extension enabled for
      <a href="http://sequel.rubyforge.org/classes/Sequel/Model.html">
      Sequel::Model
      </a> User.
      You can access the scaffolded Model at #{a('/user')}}
  end
end

Ramaze.start
