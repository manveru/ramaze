module Ramaze
  # The Response given back to the adapter, this is the center of every request
  # made.
  # In case you do a custom response, just make sure you implement all three
  # properties: out, code, head
  # where head has to respond to []
  # code is the status-code ( http://en.wikipedia.org/wiki/List_of_HTTP_status_codes )
  # and out should be something very String-like

  class ResponseStruct < Struct
    def inspect
      "<Response##{object_id} @code => #{code}, @head => #{head.inspect}, @out.size => #{out.size}>"
    end

    def pretty_inspect
      "<Response##{object_id} @code => #{code}, @head => #{head.inspect}, @out.size => #{out.size}>"
    end
  end

  Response = ResponseStruct.new(:out, :code, :head)
end
