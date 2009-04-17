#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Pretty DSL to express Sequel relations
#
# Usage:
#   SequelRelation.relations do
#     the User do
#       has_many Article
#       has_one Avatar
#     end
#
#     the Article do
#       belongs_to User
#     end
#
#     the Avatar do
#       belongs_to User
#     end
#   end

module SequelRelation
  def self.relations(&block)
    rema = RelationshipManager.new(&block)
    rema.finalize
  end

  class RelationshipManager
    TODO = {}

    def initialize(&block)
      instance_eval(&block)
    end

    def finalize
      TODO.keys.each do |model|
        model.create_table unless model.table_exists?
      end

      TODO.each do |model, instructions|
        instructions.each do |args|
          model.send(*args)
        end
      end

=begin
     # uncomment for debugging

      pp TODO

      TODO.keys.each do |model|
        puts "the #{model}"
        assoc = model.send(:association_reflections)
        assoc.each do |key, reflection|
          puts "  #{reflection[:type]} => #{key}"
        end
      end
=end
    end

    def the(left_model, &block)
      @left = left_model
      TODO[@left] = []
      instance_eval(&block)
    end

    def belongs_to(model)
      todo :many_to_one, singular_sym(model), :class => model
    end

    def has_many(model)
      todo :create_join, model
      todo :many_to_many, plural_sym(model), :class => model
    end

    def has_one(model)
      todo :many_to_one, singular_sym(model), :class => model
    end

    def todo(method, *args)
      TODO[@left] << [method, *args]
    end

    private

    def plural_sym(obj)
      basename(obj).pluralize.to_sym
    end

    def singular_sym(obj)
      basename(obj).to_sym
    end

    def basename(obj)
      obj.to_s.split('::').last.downcase
    end
  end
end
