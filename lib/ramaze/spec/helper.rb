#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

begin
  require 'rubygems'
rescue LoadError
end

require 'ramaze'
require 'ramaze/spec/helper/bacon'

def ramaze(options = {})
  appdir = File.dirname(caller[0].split(':').first)
  options = {
    :template_root => appdir/:template,
    :public_root => appdir/:public,
    :adapter      => false,
    :run_loose    => true,
    :error_page   => false,
    :port         => 7007,
    :host         => '127.0.0.1',
    :force        => true,
    :sourcereload => false,
    :origin       => :spec,
  }.merge(options)

  Ramaze.start(options)
end

SPEC_REQUIRE_DEPENDENCY = {
  'sequel' => %w[sqlite3 sequel_model sequel_core]
}

# require each of the following and rescue LoadError, telling you why it failed.
def spec_require(*following)
  following << following.map{|f| SPEC_REQUIRE_DEPENDENCY[f] }
  following.flatten.uniq.compact.reverse.each do |file|
    require file.to_s
  end
rescue LoadError => ex
  puts ex
  puts "Can't run #{$0}: #{ex}"
  puts "Usually you should not worry about this failure, just install the"
  puts "library and try again (if you want to use that feature later on)"
  exit
end

shared "http" do
  require 'ramaze/spec/helper/mock_http'
  extend MockHTTP
end

shared 'browser' do
  require 'ramaze/spec/helper/simple_http'
  require 'ramaze/spec/helper/browser'
end

shared 'requester' do
  require 'ramaze/spec/helper/mock_http'
  require 'ramaze/spec/helper/requester'
  extend Requester
  extend MockHTTP
end

shared 'xpath' do
  behaves_like 'http'

  require 'rexml/document'
  require 'rexml/xpath'

  class Rack::MockResponse
    def match(xpath = '*')
      REXML::XPath::match(REXML::Document.new(body), xpath)
    end
    alias / match
    alias search match

    def first(xpath = '*')
      REXML::XPath::first(REXML::Document.new(body), xpath)
    end
    alias at first

    def each(xpath = '*', &block)
      REXML::XPath::each(REXML::Document.new(body), xpath, &block)
    end
  end

  def xp_match(obj, xpath = '*')
    XPath::match(rexml_doc(body), xpath, &block)
  end
  alias xp_search xp_match

  def xp_first(obj, xpath = '*')
    XPath::first(rexml_doc(body), xpath, &block)
  end
  alias xp_at xp_first

  def xp_each(obj, xpath = '*', &block)
    XPath::each(rexml_doc(body), xpath, &block)
  end

  def rexml_doc(obj)
    case obj
    when REXML::Document, REXML::Element
      obj
    else
      REXML::Document.new(obj)
    end
  end
end

shared 'resolve' do
  def resolve(url)
    Ramaze::Controller::resolve(url)
  end

  def stack(url, &block)
    resolve(url).stack(&block)
  end
end
