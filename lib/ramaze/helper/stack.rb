#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module StackHelper
    private

    def call this
      (session[:STACK] ||= []) << request.request_uri
      redirect(this)
    end

    def answer
      redirect session[:STACK].pop
    end
  end
end
