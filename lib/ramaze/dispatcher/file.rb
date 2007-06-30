#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class File
      class << self
        def process(path)
          return unless file = open_file(path)
          Dispatcher.build_response(file, Ramaze::STATUS_CODE['OK'])
        end

        def open_file(path)
          file = Global.public_root/path

          if ::File.file?(file)
            response = Response.current
            response['Content-Type'] = Tool::MIME.type_for(file)
            Inform.debug("Serving static: #{file}")
            ::File.open(file, 'rb')
          end
        end
      end
    end
  end
end
