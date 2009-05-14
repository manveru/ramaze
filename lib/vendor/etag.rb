require 'digest/md5'

module Rack
  # Automatically sets the ETag header on all String bodies
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      unless headers.key?('Etag')
        hashes = []
        body.each{|chunk| hashes << chunk.hash }
        headers['Etag'] = %("#{Digest::MD5.hexdigest(hashes.join)}")
      end

      [status, headers, body]
    end
  end
end
