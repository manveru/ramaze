#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # The Response given back to the adapter, this is the center of every request
  # made.
  #
  # In case you do a custom response, just make sure you implement all three
  # properties: #out, #code, #head
  # where head has to #respond_to? #[]
  #
  # code is the status-code ( http://en.wikipedia.org/wiki/List_of_HTTP_status_codes )
  # and out should be something very String-like

  class ResponseStruct < Struct

    # get the current response out of Thread.current[:response]
    #
    # You can call this from everywhere with Ramaze::Response.current

    def current
      Thread.current[:response]
    end

    # just #inspect for this class in the format of
    #   <Response#324543 @code => 200, @head => {'Content-Type'=>'text/html', @out.size => 234>

    def inspect
      "<Response##{object_id} @code => #{code}, @head => #{head.inspect}, @out.size => #{out.size}>"
    end
    alias pretty_inspect inspect

    # same as #head['Content-Type']

    def content_type
      head['Content-Type']
    end
  end

  Response = ResponseStruct.new(:out, :code, :head)
end
