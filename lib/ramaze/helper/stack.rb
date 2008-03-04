#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # provides an call/answer mechanism, this is useful for example in a
  # login-system.
  #
  # It is basically good to redirect temporarly somewhere else without
  # forgetting where you come from and offering a nice way to get back
  # to the last urls.
  #
  # Example:
  #
  # class AuthController < Controller
  #   helper :stack
  #
  #   def login pass
  #     if pass == 'password'
  #       session[:logged_in] = true
  #       answer if inside_stack?
  #       redirect '/'
  #     else
  #       "failed"
  #     end
  #   end
  #
  #   def logged_in?
  #     !!session[:logged_in]
  #   end
  # end
  #
  # class ImportantController < Controller
  #   helper :stack
  #
  #   def secret_information
  #     call :login unless logged_in?
  #     "Agent X is assigned to fight the RubyNinjas"
  #   end
  # end

  module Helper::Stack
    # redirect to another location and pushing the current location
    # on the session[:STACK]

    def call this
      (session[:STACK] ||= []) << request.fullpath
      redirect this
    end

    # return to the last location on session[:STACK]

    def answer
      if inside_stack?
        stack = session[:STACK]
        target = stack.pop
        session.delete(:STACK) if stack.empty?
        redirect target
      end
    end

    # check if the stack has something inside.

    def inside_stack?
      session[:STACK] and session[:STACK].any?
    end
  end
end
