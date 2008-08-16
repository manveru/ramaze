#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module CoreExtensions

    # Extensions for Symbol

    module Symbol
      unless :to_proc.respond_to?(:to_proc)

        # Turns the symbol into a simple proc, which is especially useful for enumerations. Examples:
        #
        #   # The same as people.collect { |p| p.name }
        #   people.collect(&:name)
        #
        #   # The same as people.select { |p| p.manager? }.collect { |p| p.salary }
        #   people.select(&:manager?).collect(&:salary)
        #
        #   [1, 2, 3].map(&:to_s)    # => ['1', '2', '3']
        #   %w[a b c].map(&:to_sym)  # => [:a, :b, :c]

        def to_proc
          Proc.new{|*args| args.shift.__send__(self, *args) }
        end
      end
    end

  end
end
