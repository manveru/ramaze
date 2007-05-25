#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FileHelper
    private

    # Sets Content-Type to the mimetype of the file and opens the file you pass
    # it, then throws :respond to finish off the request.

    def send_file(file, mime_type = Tool::MIME.type_for(file))
      response.header["Content-Type"] = mime_type
      response.body = File.open(file)
      throw(:respond)
    end
  end
end
