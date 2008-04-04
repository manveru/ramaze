require 'rubygems'
require 'ramaze'
require 'sequel'
require 'scaffolding_extensions'

DB = Sequel.sqlite

class User < Sequel::Model(:user)
  set_schema do
    primary_key :id
    varchar :name
    text :description
  end

  create_table
end

ScaffoldingExtensions.all_models = [User]

class UserController < Ramaze::Controller
  scaffold_all_models :only => [User]
end

Ramaze.start
