#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class File
      class << self
        def process(path)
          return unless file = open_file(path)
          Dispatcher.build_response(file, Ramaze::STATUS_CODE[:ok])
        end

        def lookup_paths
          [ (BASEDIR/'proto'/'public'),
            Global.controllers.map{|c| c.trait[:public]},
            './public'
          ].flatten.select{|f| ::File.directory?(f.to_s)}.map{|f| ::File.expand_path(f)}
        end

        def open_file(path)
          paths = lookup_paths.map{|pa| pa/path}
          file = paths.find{|way| ::File.file?(way)}

          if file
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
