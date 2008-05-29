#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity'

module Ramaze

  # A module used by the Templates and the Controllers
  # it provides both Ramaze::Trinity (request/response/session)
  # and also a helper method, look below for more information about it

  module Helper
    LOOKUP = Set.new
    PATH = ['']
    trait :ignore => [
      /#{Regexp.escape(File.expand_path(BASEDIR/'../spec/ramaze/helper/'))}\//
    ]

    module Methods
      def self.included other
        other.send :extend, Trinity
        other.send :extend, Methods
        other.send :include, Trinity
        super
      end

      def self.extend_object other
        other.send :extend, Trinity
        super
      end

      # This loads the helper-files from /ramaze/helper/helpername.rb and
      # includes it into Ramaze::Template (or wherever it is called)
      #
      # Usage:
      #   helper :redirect, :link

      def helper(*syms)
        syms.each do |sym|
          name = sym.to_s
          if mod = find_helper(name)
            use_helper(mod)
          else
            if require_helper(name)
              redo
            else
              raise LoadError, "#{name} not found"
            end
          end
        end
      end

      private

      def find_helper(name)
        name = name.to_s.camel_case
        ramaze_helper_consts = ::Ramaze::Helper.constants.grep(/^#{name}$/i)
        if mod_name = ramaze_helper_consts.first
          ::Ramaze::Helper.const_get(mod_name)
        end
      end

      def require_helper(name)
        paths = (PATH + [Global.root, BASEDIR/:ramaze]).join(',')
        glob = "{#{paths}}/helper/#{name}.{so,bundle,rb}"
        files = Dir[glob]
        ignore = Helper.trait[:ignore]
        files.reject!{|f| ignore.any?{|i| f =~ i }}
        raise LoadError, "#{name} not found" unless file = files.first
        require(file)
      end

      def use_helper(mod)
        include mod
        extend mod
      end
    end
  end
end
