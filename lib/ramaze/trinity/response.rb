#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # get the current response out of Thread.current[:response]
  #
  # You can call this from everywhere with Ramaze::Response.current

  def self.Response
    Thread.current[:response]
  end
end
