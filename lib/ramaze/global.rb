#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Global
    class << self
      @@table = {}

      def create(h = {})
        @@table = Thread.main[:global] = h
      end

      def table
        @@table
      end

      def update(h = {})
        create unless @@table
        @@table = h.merge(@@table)
      end

      def [](key)
        @@table[key.to_sym]
      end

      def []=(key, value)
        @@table[key.to_sym] = value
      end

      def method_missing(meth, *args, &block)
        if meth.to_s[-1..-1] == '='
          key = meth.to_s[0..-2].to_sym
          @@table.send("[]=", key, *args)
        elsif args.empty?
          @@table[meth] ||= nil
        else
          @@table.send(meth, *args, &block)
        end
      rescue
        super
      end

      def inspect
        @@table.inspect
      end

      def pretty_inspect
        @@table.pretty_inspect
      end

    end # class << self
  end # Global
end # Ramaze
