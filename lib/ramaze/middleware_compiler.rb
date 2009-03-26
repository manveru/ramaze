module Ramaze
  class MiddlewareCompiler < Innate::MiddlewareCompiler
    def static(path)
      require 'rack/contrib'
      Rack::ETag.new(Rack::ConditionalGet.new(Rack::File.new(path)))
    end

    def directory(path)
      require 'rack/contrib'
      Rack::ETag.new(Rack::ConditionalGet.new(Rack::Directory.new(path)))
    end
  end
end
