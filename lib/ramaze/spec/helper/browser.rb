#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Browser
  attr_reader :cookie, :http

  def initialize(url = '/', base = '/', &block)
    @base     = base
    @history  = []
    @http     = SimpleHttp.new(url2uri(url))

    get url

    story(&block) if block_given?
  end

  def story(&block)
    instance_eval(&block) if block_given?
  end

  def get url = '/', hash = {}
    request(:get, url, hash)
  end

  def post url = '/', hash = {}
    request(:post, url, hash)
  end

  def erequest method, url, hash = {}
    response = request(method, url, hash)
    eval(response)
  rescue Object => ex
    p :response => response
    ex.message
  end

  def epost url = '/', hash = {}
    erequest(:post, url, hash)
  end

  def eget url = '/', hash = {}
    erequest(:get, url, hash)
  end

  def hget(*args)
    @page = Hpricot(get(*args))
  end

  def hpost(*args)
    @page = Hpricot(post(*args))
  end

  def find_link(text)
    link = @page.at("a[text()='#{text}']")
    link.should.not.be.nil if link.respond_to?(:should)
    link[:href]
  end

  def follow_link(text)
    hget find_link(text)
  end

  def follow_links(*texts)
    texts.each do |text|
      follow_link text
    end
  end

  def request method, url, hash = {}
    @http.uri = url2uri(url)
    @http.request_headers['referer'] = @history.last.path rescue '/'

    if method == :get and not hash.empty?
      @http.uri.query = hash.inject([]){|s,(k,v)| s << "#{k}=#{v}"}.join('&')
      hash.clear
    end

    response = @http.send(method, hash).strip
    @history << @http.uri
    get_cookie

    response
  end

  def get_cookie
    @cookie = @http.response_headers['set-cookie']
    @http.request_headers['cookie'] = @cookie
  end

  def url2uri url
    uri = URI.parse(url)
    uri.scheme = 'http'
    uri.host = 'localhost'
    uri.port = Ramaze::Global.port
    uri.path = "/#{@base}/#{url}".squeeze('/')
    uri
  end
end
