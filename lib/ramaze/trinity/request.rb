#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'

module Ramaze
  class Request
    attr_accessor :request
    def initialize request = {}
      @request = request
      parse_queries
    end

    def method_missing meth, *args, &block
      if value = @request.params[meth.to_s.upcase] rescue false
        value
      else
        @request.send(meth, *args, &block)
      end
    end

    def params
      @params ||= [
        @get_query, @post_query, @put_query, @delete_query
      ].inject({}) do |sum, hash|
        sum.merge(hash)
      end
    end

    # this parses stuff like post-requests (very untested)
    # and also ?foo=bar stuff (get-query)
    # WEBrick uses body as a streaming-object, so we have to #read.
    # Mongrel has a normal string as body, we just call to_s in case
    # it's no POST

    def parse_queries
      @get_query = @post_query = @delete_query = @put_query = {}

      case request_method
      when 'GET'    : process_get
      when 'POST'   : process_post
      when 'PUT'    : process_put
      when 'DELETE' : process_delete
      end
    end

    def process_post
      type, boundary = content_type.split(';')

      if type.downcase == 'multipart/form-data' and not boundary.empty?
        parse_multipart(body, boundary.split('=').last)
      else
        post_query = query_parse(body.respond_to?(:read) ? body.read : body)
        post_query.each do |key, value|
          @post_query[CGI.unescape(key)] = CGI.unescape(value)
        end
      end
    end

    def process_get
      get_query = query_parse(query_string) rescue {}
      get_query.each do |key, value|
        @get_query[CGI.unescape(key)] = CGI.unescape(value)
      end
    end

    def process_delete
      raise "Implement me"
    end

    def process_put
      put_query = query_parse(query_string) rescue {}
      put_query.each do |key, value|
        @put_query[CGI.unescape(key)] = CGI.unescape(value)
      end
      @put_query['PUT'] = body.read
    end

    def query_parse str
      str = str.split('?').last.to_s rescue ''
      hash = CGI.parse(str)
      hash.each do |key, values|
        key = CGI.unescape(key)
        values = values.map{|v| CGI.unescape(v)}
        hash[key] = values.size == 1 ? values.first : values
      end
      hash
    end

    def parse_multipart(body, boundary)
      text = body.read
      text.split("--" << boundary).each do |chunk|
        header = chunk.split("\r\n\r\n").first
        next if (!header or !body) || (header.strip.empty? or chunk.strip.empty?)
        head = parse_multipart_head(header)
        next if head.empty?
        chunk = chunk[(header.size + 4)..-3]
        hash = Digest::MD5.hexdigest([head['name'], chunk.size, head.hash].inspect)
        filename = File.join(Dir.tmpdir, hash)
        File.open(filename, "w+") do |file|
          file.print(chunk)
        end
        @post_query[head['name']] = File.open(filename)
      end
      body.rewind
    end

    def parse_multipart_head(string)
      string.gsub("\r\n", ";").split(';').inject({}) do |sum, param|
        key, value = param.strip.split('=')
        sum[key] = value[1..-2] if key and value
        sum
      end
    end

    def [](key)
      @post_query[key]
    end

    def []=(key, value)
      @post_query[key] = value
    end

    def post_query
      @post_query
    end

    def get_query
      @get_query
    end

    def get?()    request_method == 'GET'    end
    def post?()   request_method == 'POST'   end
    def put?()    request_method == 'PUT'    end
    def delete?() request_method == 'DELETE' end

    def local?
      remote_addr == '127.0.0.1'
    end
  end
end
