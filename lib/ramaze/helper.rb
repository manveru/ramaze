#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity'

module Ramaze

  # A module used by the Templates and the Controllers
  # it provides both Ramaze::Trinity (request/response/session)
  # and also a helper method, look below for more information about it

  module Helper
    LOOKUP = Set.new
    IGNORE = [] unless defined?(IGNORE)

    include Trinity

    private

    # This loads the helper-files from /ramaze/helper/helpername.rb and
    # includes it into Ramaze::Template (or wherever it is called)
    #
    # Usage:
    #   helper :redirect, :link

    def helper *syms
      syms.each do |sym|
        mod_name = sym.to_s.camel_case + 'Helper'
        begin
          include ::Ramaze.const_get(mod_name)
          extend ::Ramaze.const_get(mod_name)
        rescue NameError
          glob = "{,#{APPDIR},#{BASEDIR/:ramaze}}/helper/#{sym}.{so,bundle,rb}"
          files = Dir[glob]
          files.reject!{|file| IGNORE.any?{|ignore| file =~ ignore } }
          raise LoadError, "#{mod_name} not found" unless files.any?
          require(files.first) ? retry : raise
        end
      end
    end
  end
end
