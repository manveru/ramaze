#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity'

module Ramaze

  # A module used by the Templates and the Controllers
  # it provides both Ramaze::Trinity (request/response/session)
  # and also a helper method, look below for more information about it

  module Helper
    include Ramaze::Trinity

    private

    # This loads the helper-files from /ramaze/helper/helpername.rb and
    # includes it into Ramaze::Template (or wherever it is called)
    #
    # Usage:
    #   helper :redirect, :link

    def helper *syms
      syms.each do |sym|
        require "ramaze/helper/#{sym}"
        include ::Ramaze.const_get("#{sym.to_s.capitalize}Helper")
      end
    end
  end
end
