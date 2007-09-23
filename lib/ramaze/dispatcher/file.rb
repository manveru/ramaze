#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher

    # First of the dispatchers, looks up the public path and serves the
    # file if found.

    class File
      class << self

        # Entry point from Dispatcher::filter.
        # searches for the file and builds a response with status 200 if found.

        def process(path)
          return unless file = open_file(path)
          Response.current.build(file, Ramaze::STATUS_CODE['OK'])
        end

        # returns file-handle with the open file on success, setting the
        # Content-Type as found in Tool::MIME

        def open_file(path)
          file = resolve_path(path)
          if ::File.file?(file)
            response = Response.current
            response['Content-Type'] = Tool::MIME.type_for(file)
            Inform.debug("Serving static: #{file}")
            ::File.open(file, 'rb')
          end
        end

        def resolve_path(path)
          file = ::File.join(Global.public_root, path =~ /\/$/ ? path + 'index' : path)
        end
      end
    end
  end
end
