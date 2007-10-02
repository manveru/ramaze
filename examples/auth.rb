require 'rubygems'
require 'sequel/sqlite'

DB = Sequel.sqlite
class User < Sequel::Model(:users)
  set_schema do
    primary_key :id
    varchar :username
    varchar :password
  end
end

unless User.table_exists?
  User.create_table
  User.create :username => 'admin', :password => 'passwort'
end

require 'ramaze'

class MainController < Ramaze::Controller
  helper :auth
  layout :layout
  trait :engine => Ramaze::Template::Haml
  
  def index
    login_required
    "Hello #{session[:username]}"
  end
  
  def login
    super
%{
- unless logged_in?
  %form{ :method => 'POST', :action => Rs(:login) }
    %ul
      %li
        username:
        %input{ :type => 'text', :name => 'username' }/
      %li
        password:
        %input{ :type => 'password', :name => 'password' }/
      %li
        %input{ :type => 'submit', :name => 'login' }/
- else
  click here to
  %a{ :href => Rs(:logout) } logout
}
  end
  
  def layout
%{
!!!
%html
  %head
    %title Auth Example
    %style
      :sass
        body
          :margin 5em
          :padding 1em
          :border 1px solid black
          ul
            :list-style none
  %body
    = @content
}
  end
  
  private
  
  def check_auth user, pass
    !User[:username => user, :password => pass ].nil?
  end
end

Ramaze.start :adapter => :evented_mongrel