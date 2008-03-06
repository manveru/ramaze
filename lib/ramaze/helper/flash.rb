#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # The purpose of this class is to provide an easy way of setting/retrieving
  # from the current flash.
  #
  # Flash is a way to keep a temporary pairs of keys and values for the duration
  # of two requests, the current and following.
  #
  # Very vague Example:
  #
  # On the first request, for example on registering:
  #
  #   flash[:error] = "You should reconsider your username, it's taken already"
  #   redirect R(self, :register)
  #
  # This is the request from the redirect:
  #
  #   do_stuff if flash[:error]
  #
  # On the request after this, flash[:error] is gone.

  module Helper::Flash
    trait :tag => "<div class='flash' id='flash_%key'>%value</div>"
    # answers with Session.current.flash

    def flash
      Session.current.flash
    end

    def flashbox(tag = Helper::Flash.trait[:tag])
      flash.sort.map{|(key, value)|
        tag.gsub(/%key/, key).gsub(/%value/, value)
      }.join("\n")
    end
  end
end
