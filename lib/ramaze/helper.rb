#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity'

module Ramaze

  # A module used by the Templates and the Controllers
  # it provides both Ramaze::Trinity (request/response/session)
  # and also a helper method, look below for more information about it

  module Helper
    LOOKUP = Set.new
    trait :ignore => [
      /#{Regexp.escape(File.expand_path(BASEDIR/'../spec/ramaze/helper/'))}\//
    ]

    module Methods
      private

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

      # Will be going to be much simpler after deprecation *sigh*
      def find_helper(name)
        ramaze_helper_consts = ::Ramaze::Helper.constants.grep(/^#{name}$/i)
        ramaze_consts = ::Ramaze.constants.grep(/^#{name}Helper$/i)
        if mod_name = ramaze_helper_consts.first
          ::Ramaze::Helper.const_get(mod_name)
        elsif mod_name = ramaze_consts.first
          mod = ::Ramaze.const_get(mod_name)
          new_name = "Ramaze::Helper::" << mod_name.split('::').last[/^(.*)Helper$/, 1]
          Log.warn "#{mod_name} is being deprecated, use #{new_name} instead"
          mod
        end
      end

      def require_helper(name)
        glob = "{,#{APPDIR},#{BASEDIR/:ramaze}}/helper/#{name}.{so,bundle,rb}"
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

      def Methods.included other
        other.send :extend, Trinity
        other.send :include, Trinity
        other.send :extend, Methods
        super
      end

      def Methods.extend_object other
        other.send :extend, Trinity
        super
      end
    end
  end
end
