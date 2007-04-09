module Ramaze
  module Dispatcher
    class File
      class << self
        def process(path)
          file = open_file(path)
          return unless file
          Dispatcher.build_response(file, Ramaze::STATUS_CODE[:ok])
        end

        def open_file(path)
          custom_publics = Global.controllers.map{|c| c.trait[:public]}.compact
          the_paths = $:.map{|way| (way/'public'/path) }
          the_paths << (BASEDIR/'proto'/'public'/path)
          the_paths += custom_publics.map{|c| c/path   }
          file = the_paths.find{|way| ::File.file?(way)}

          if file
            response = Response.current
            response['Content-Type'] = Tool::MIME.type_for(file)
            Informer.debug("Serving static: #{file}")
            ::File.open(file, 'rb')
          end
        end
      end
    end
  end
end
