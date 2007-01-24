#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module CrudHelper
    def self.included(obj)
      Global.mapping ||= {}

      obj.class_eval do
        class << self

          def crud(klass, routes = {})
            default_routes = {
              'create' => :create,
              'read'   => :read,
              'update' => :update,
              'delete' => :delete,
            }

            klass.trait[:crud_routes] = default_routes.merge(routes)
            klass.trait[:actionless] = true

            klass.extend(Trinity)

            def klass.handle_request(action, *args)
              meth = trait[:crud_routes][action] || action
              send(meth, *args).to_s
            end

            name = routes.delete(:name) || klass.name
            name = ('/' << name).squeeze('/')

            Global.mapping[name] = klass
          end

        end
      end
    end
  end
end
