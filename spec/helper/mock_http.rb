require 'ramaze'
require 'rack/mock'

module Ramaze
  module Adapter
    class Fake < Base
    end
  end
end

module MockHTTP
  DEFAULTS = {
    'REMOTE_ADDR' => '127.0.0.1'
  }

  MOCK_URI = URI::HTTP.build(
    :host => 'localhost',
    :port => 80
  )

  def get(path, query = {})
    uri = create_url(path, query)
    mock_request.get(uri, DEFAULTS)
  end

  def post(path, query = {})
    input = query.delete(:input)
    uri = create_url(path, query)
    if input
      mock_request.post(uri, DEFAULTS.merge(:input => input))
    else
      mock_request.post(uri, DEFAULTS)
    end
  end

  def put(path, query = {})
    input = query.delete(:input)
    uri = create_url(path, query)
    if input
      mock_request.put(uri, DEFAULTS.merge(:input => input))
    else
      mock_request.put(uri, DEFAULTS)
    end
  end

  def delete(path, query = {})
    uri = create_url(path, query)
    mock_request.delete(uri, DEFAULTS)
  end

  def create_url(path, query)
    uri = MOCK_URI.dup
    uri.path = path
    uri.query = make_query(query)
    uri.to_s
  end

	def make_query query
		return query unless query && query.class == Hash
    query.inject([]) do |s, (key, value)|
			s + [CGI::escape(key) + "=" + CGI::escape(value)]
    end.join('&')
	end

  def mock_request
    ::Rack::MockRequest.new(Ramaze::Adapter::Fake)
  end
end
