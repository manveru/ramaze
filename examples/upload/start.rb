require 'rubygems'
require 'ramaze'
require 'cgi'
require 'ftools'

class MainController < Ramaze::Controller
    def index
        if request.post?
            @inspection = CGI.escapeHTML( PP.pp( request.params, "" ) )
            
            file = request[ 'file' ][ :tempfile ]
            @file_size = file.stat.size
            filename = request[ 'file' ][ :filename ]
            @extension = File.extname( filename )
            @ext_name = File.basename( filename )
            File.move( file.path, 'public/' + @ext_name )
            @is_image = [
                '.png', '.jpeg', '.jpg', '.gif', '.tiff'
            ].include?( @extension.downcase )
        end
    end
end

Ramaze.start