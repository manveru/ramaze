=begin

A little transcript of how to use this example, you may use your browser
instead of curl, I just do it this way since it is easier to demonstrate.

Also, feel free to use something else than Og, here I use it for pure
convenience.


[manveru@delta ~]$ curl localhost:7000/User/

[manveru@delta ~]$ curl localhost:7000/User/create?name=manveru
  #<User:0xb6599578 @errors=#<Glue::Validation::Errors:0xb65994ec @errors={}>, @name="manveru", @oid=1>

[manveru@delta ~]$ curl localhost:7000/User/create?name=foobar
  #<User:0xb65460d0 @errors=#<Glue::Validation::Errors:0xb64c212c @errors={}>, @name="foobar", @oid=2>

[manveru@delta ~]$ curl localhost:7000/User/
  #<User:0xb64b448c @name="manveru", @oid=1>
  #<User:0xb64b4018 @name="foobar", @oid=2>

[manveru@delta ~]$ curl localhost:7000/User/read/1
  #<User:0xb65d16a8 @name="manveru", @oid=1>

[manveru@delta ~]$ curl localhost:7000/User/read/2
  #<User:0xb65c4d18 @name="foobar", @oid=2>

[manveru@delta ~]$ curl localhost:7000/User/update/2?name=barfoo
  1

[manveru@delta ~]$ curl localhost:7000/User/read/2
  #<User:0xb64885a8 @name="barfoo", @oid=2>

[manveru@delta ~]$ curl localhost:7000/User/
  #<User:0xb65c3bac @name="manveru", @oid=1>
  #<User:0xb65c374c @name="barfoo", @oid=2>

[manveru@delta ~]$ curl localhost:7000/User/delete/2
  true

[manveru@delta ~]$ curl localhost:7000/User/
  #<User:0xb65169d4 @name="manveru", @oid=1>

[manveru@delta ~]$ curl localhost:7000/User/delete/1
  true

[manveru@delta ~]$ curl localhost:7000/User/

=end

require 'ramaze'
require 'og'

# this is the object that CrudHelper hooks on.
# all methods that you want to access from outside have to be
# public class-methods.

class User
  attr_accessor :name, String

  class << self
    def crud_index
      self.all.map{|s| s.inspect}.join("\n")
    end

    def crud_create
      obj = create_with(request.params)
      obj.inspect
    end

    def crud_read(oid)
      self[oid.to_i].inspect
    end

    def crud_update(oid)
      obj = self[oid.to_i]
      request.params.each do |k, v|
        obj.send("#{k}=", v) if obj.respond_to?("#{k}=")
      end
      obj.save
    end

    def crud_delete(oid)
      self[oid.to_i].delete
    end
  end
end

include Ramaze

class MainController < Template::Ramaze
  helper :crud
  crud User, 'index'  => :crud_index,
             'create' => :crud_create,
             'read'   => :crud_read,
             'update' => :crud_update,
             'delete' => :crud_delete
end

Og.setup :store => :sqlite

start
