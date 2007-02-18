#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'

module Ramaze

  # This class is used for processing the information coming in from a request
  # to the dispatcher, it takes the original request-object, processes it and
  # is later available in the controller or as Thread.current[:request]
  #
  # Please note that the implementation is lacking performance and security
  # in favor of simplicity. Hopefully I (or some CGI-guru) will come along
  # and implement this properly, until then consider it unsafe, but functional.
  #
  # Most information you will need is in the #params, which is a compound of
  # all the information available from POST, GET, DELETE and PUT.

  class Request
    #attr_accessor :request, :post_query, :get_query, :puts_query, :get_query

    class << self

      # get the current request out of Thread.current[:request]
      #
      # You can call this from everywhere with Ramaze::Request.current

      def current
        Thread.current[:request]
      end
    end

    # create a new instance of Request, takes the original request-object
    # and runs #parse_queries to extract/process the information inside

    def initialize request = {}
      @request = request
    end

    def [](key)
      @request.params[key]
    end

    def []=(key, value)
      @request.params[key] = value
    end

    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request

    def method_missing meth, *args, &block
      @request.send(meth, *args, &block)
    rescue
      @request.env[meth.to_s.upcase]
    end
  end
end


=begin
      if value = @request.params[meth.to_s.upcase] rescue false
        value
      else
        @request.send(meth, *args, &block)
      end
    end

    # containts all the parameters given, no matter wheter with
    # POST, GET, PUT or DELETE
    # answers with a hash that is generated from the respective
    # _query instance-variables and cached subsequently in @params

    def params
      @params ||= [
        @get_query, @post_query, @put_query, @delete_query
      ].inject({}) do |sum, hash|
        sum.merge(hash || {})
      end
    end

    # this parses stuff like post-requests (very untested)
    # and also ?foo=bar stuff (get-query)
    # WEBrick uses body as a streaming-object, so we have to #read.
    # Mongrel has a normal string as body, we just call to_s in case
    # it's no POST

    def parse_queries
      case request_method
      when 'GET'    : process_get
      when 'POST'   : process_post
      when 'PUT'    : process_put
      when 'DELETE' : process_delete
      end
    end

    # very naive implementation of POST-body parsing, this won't withstand
    # any serious testing or multiple simultanous huge posts...
    # However, it just extracts the information inside the @request.body
    # and puts it into proper form
    # you can access its contents via #post_query

    def process_post
      @post_query = {}

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

    # processing incoming GET, stuffing the results into @get_query,
    # you can access the information via #get_query

    def process_get
      @get_query = {}

      get_query = query_parse(query_string) rescue {}
      get_query.each do |key, value|
        @get_query[CGI.unescape(key)] = CGI.unescape(value)
      end
    end

    # TODO
    # - implement and test DELETE

    def process_delete
      @delete_query = {}
      raise "Implement me"
    end

    # again, rather naive, it just gives you the control over what to do
    # with the #body but will parse the parameters from the URL

    def process_put
      @pust_query = {}

      put_query = query_parse(query_string) rescue {}
      put_query.each do |key, value|
        @put_query[CGI.unescape(key)] = CGI.unescape(value)
      end
    end

    # process the parameters passed over the URL, they look like
    #
    # http://foo.bar/action?eins=one&zwei=two
    #
    # that would result in #params containing {'eins' => 'one', 'zwei' => 'two'}

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

    # parse multipart-requests, just pass it something that responds to .read
    # and a boundary for the parts.
    # again a naive implementation without any guarantee against DoS.
    #
    # TODO:
    #  - rewrite parsing of multipart
    #  - chunk through the body and pipe into tempfile
    #  - look at merb for example of correct parsing

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

    # parse the head of the one part of multipart
    # you most likely won't have to use this on your own :)

    def parse_multipart_head(string)
      string.gsub("\r\n", ";").split(';').inject({}) do |sum, param|
        key, value = param.strip.split('=')
        sum[key] = value[1..-2] if key and value
        sum
      end
    end

    # like request.params[key]

    def [](key)
      params[key]
    end

    # like reuqest.params[key] = value

    def []=(key, value)
      params[key] = value
    end

    # request_method == 'GET'
    def get?()    request_method == 'GET'    end
    # request_method == 'POST'
    def post?()   request_method == 'POST'   end
    # request_method == 'PUT'
    def put?()    request_method == 'PUT'    end
    # request_method == 'DELETE'
    def delete?() request_method == 'DELETE' end

    # remote_addr == '127.0.0.1'

    def local?
      remote_addr == '127.0.0.1'
    end

    # Is the request coming from a local network?

    def local_net?(ip = remote_addr)
      bip = ip.split('.').map{ |x| x.to_i }.pack('C4').unpack('N')[0]

      # 127.0.0.1/32    => 2130706433
      # 192.168.0.0/16  => 49320
      # 172.16.0.0/12   => 2753
      # 10.0.0.0/8      => 10

      { 0 => 2130706433, 16 => 49320, 20 => 2753, 24 => 10}.each do |s,c|
        return true if (bip >> s) == c
      end

      return false
    end

    # check the referer from which the browser came
    # '/' if no referer given.

    def referer
      headers['HTTP_REFERER'] || '/'
    rescue
      params['HTTP_REFERER'] || '/'
    end
  end
end
=end
