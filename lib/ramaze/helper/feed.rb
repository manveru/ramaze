#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FeedHelper
    def feed
    end
  end
end

module ReFeed
  def self.included(klass)
    klass.class_eval do
      const_set('XML_ATTRIBUTES', {})

      class << self
        def xml_accessor(*args)
          args = xml(*args)
          attr_accessor(*args)
        end

        def xml(*arguments)
          args = []
          hash = nil
          klass = Object.const_get(self.to_s)

          arguments.each do |arg|
            if arg.respond_to?(:to_sym)
              args << arg.to_sym
            elsif arg.respond_to?(:to_hash)
              hash = arg
            end
          end

          args.each do |arg|
            klass::XML_ATTRIBUTES[arg] = hash
          end
        end
      end
    end
  end

  def xml_attributes
    self.class::XML_ATTRIBUTES
  end

  def to_xml
    name = self.class.name
    xml = xml_attributes.map do |key, opts|
      value = send(key)
      next unless value
      if value.respond_to?(:to_xml)
        value.to_xml
      elsif value.respond_to?(:all?) and value.all?{|v| v.respond_to?(:to_xml) }
        value.map{|v| v.to_xml }
      else
        "<#{key}>#{value}</#{key}>"
      end
    end
    "<#{name}>#{xml}</#{name}>"
  end
end

=begin
module Ramaze
  module FeedHelper
    def feed_rss(&block)
    end

    def feed_atom(&block)
    end

    def feed(protocol = :atom, &block)
      this = send("feed_#{protocol}", &block).to_s
      p :feed => this
      this
    end
  end
end

=begin

module Feed
  class Bag
    undef_method :id if instance_methods.include?(:id)

    def initialize(&block)
      @tags = {}
      instance_eval(&block) if block_given?
    end

    def method_missing(meth, *args, &block)
      self.class.send(:attr_accessor, meth)

      if block_given?
        klass = self.class.name.split('::')[1]
        klass = ::Feed.const_get(klass).const_get(meth.to_s.capitalize)
        @tags[meth] = instance_variable_set("@#{meth}", klass.new(&block))
      else
        value = args.size == 1 ? args.first : args
        @tags[meth] = instance_variable_set("@#{meth}", value)
      end
    end

    def uuid
      "unique id"
    end

    def each
      @tags.each{|t| yield(t)}
    end

    def map
      @tags.map{|t| yield(t)}
    end

    def transform(indent = '  ')
      name = self.class.name.split('::').last.downcase
      [
        "#{indent}<#{name}>",
        tags(indent),
        out << "#{indent}</#{name}>",
      ].join
    end

    def tags(indent = '  ')
      map do |key, value|
        if key == :link
          %{#{indent}  <#{key} href="#{value}" />}
        else
          if value.is_a?(Bag)
            value.transform(indent + '  ')
          else
            %{#{indent}  <#{key}>#{value}</#{key}>}
          end
        end
      end
    end
  end
end

=begin
atom =
  Feed::Atom::Feed.new do
  title "Example Feed"
  subtitle "A subtitle."
  link "http://example.org/"
  id uuid

  author do
    name "John Doe"
    email "johndoe@example.com"
  end

  entry do
    title "Atom-Powered Robots Run Amok"
    link "http://example.org/2003/12/13/atom03"
    summary "Some text."
    id uuid
  end
end

puts atom
=end

=begin
module Feed::Atom
  STRFTIME = "%Y-%m-%d"

  class AtomBag < ::Feed::Bag
    def to_s
      [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<feed xmlns="http://www.w3.org/2005/Atom">',
        transform,
        '</feed>',
      ].join("\n")
    end
  end

  class Feed < AtomBag; end
  class Entry < AtomBag; end
  class Author < AtomBag; end
end

module Feed
  def self.RSS(version = 2.0)
    klass = "RSS_#{version}".split('.').join('_')
    const_get(klass)
  end
end

=begin
rss =
Feed::RSS(2.0)::Channel.new do
  title "Liftoff News"
  link "http://liftoff.msfc.nasa.gov/"
  description "Liftoff to Space Exploration."
  language "en-us"
  pubDate Time.now
  lastBuildDate Time.now
  docs "http://blogs.law.harvard.edu/tech/rss"
  generator "Weblog Editor 2.0"
  managingEditor "editor@example.com"
  webMaster "webmaster@example.com"

  item do
    title "Star City"
    link "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"
    description "How do Americans get ready to work with Russians aboard the
                 International Space Station? They take a crash course in culture, language
                 and protocol at Russia's Star City."
    pubDate Time.now
    guid "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573"
  end
end

puts rss.to_rss
=end

=begin
module Feed::RSS_2_0
  STRFTIME = "%Y-%m-%d"

  class RSSBag < ::Feed::Bag
    def to_s
      [
        '<?xml version="1.0"?>',
        '<rss version="2.0">',
        transform,
        '</rss>',
      ].join("\n")
    end
  end

  class Feed < RSSBag; end
  class Item < RSSBag; end
  class Channel < RSSBag; end
end
=end
