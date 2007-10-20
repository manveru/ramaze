# gzip_filter.rb
#
# Use this to compress "large" pages with gzip.  All major browsers support gzipped pages.
# This filter brought to you by your friends in #ramaze: Pistos, manveru, rikur and Kashia.
#
# Usage:
# in start.rb:
#
# require 'path/to/gzip-filter'
# Ramaze::Dispatcher::Action::FILTER.push Ramaze::Filter::Gzip

require 'zlib'

module Ramaze; module Filter
class Gzip

    trait :enabled => true
    trait :threshold => 32768 # bytes

    class << self

        include Ramaze::Trinity

        # Enables being plugged into Dispatcher::Action::FILTER

        def call( response, options = {} )
            return response if not trait[ :enabled ]
            return response if response.body.nil?
            return response if response.body.respond_to?( :read )

            accepts = request.env[ 'HTTP_ACCEPT_ENCODING' ]
            return response if accepts.nil? || ( accepts !~ /(x-gzip|gzip)/ )

            if response.content_type == 'text/html' && response.body.size > trait[ :threshold ]
                output = StringIO.new
                def output.close
                    # Zlib closes the file handle, so we want to circumvent this
                    rewind
                end
                gz = Zlib::GzipWriter.new( output )
                gz.write( response.body )
                gz.close

                response.body = output.string
                response.header[ 'Content-encoding' ] = 'gzip'
            end

            response
        end
    end
end
end; end
