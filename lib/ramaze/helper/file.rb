#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FileHelper
    def send_file(file, mime_type = Tool::MIME.type_for(file))
      response.header["Content-Type"] = mime_type
      response.body = File.open(file)
      throw(:respond)
    end
  end
end
