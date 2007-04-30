module Ramaze
  module FileHelper
    def send_file(file, mime_type = Tool::MIME.type_for(file))
      response.header["Content-Type"] = mime_type
      response.body = File.open(file)
      throw(:respond)
    end
  end
end
