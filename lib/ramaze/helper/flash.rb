#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FlashHelper
    private

    def flash
      Session.current.flash
    end
  end
end
