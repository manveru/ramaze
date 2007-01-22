#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze
  module CrudHelper
    def self.included(obj)
      obj.class_eval do
        class << self
          def crud(*klasses)
            klasses.each do |klass|
              p self
              define_method(klass.name.to_sym) do |*args|
                klass.send(*args)
              end
            end
          end
        end
      end
    end

    def go_read(obj)
      R(self, obj.class, :read, obj.oid)
    end
  end
end
