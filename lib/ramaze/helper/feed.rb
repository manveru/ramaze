module Ramaze
  module FeedHelper
    def rss_feed(&block)
      Feed::RSS(2.0)::Channel.new(&block)
    end

    def atom_feed(&block)
      Feed::Atom::Feed.new(&block)
    end
  end
end

module Feed
  class Bag
    undef_method :id if defined?(id)

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

    def to_s(indent = '  ')
      name = self.class.name.split('::').last.downcase
      [
        "#{indent}<#{name}>",
        tags(indent),
        out << "#{indent}</#{name}>",
      ]
    end

    def tags(indent = '  ')
      map do |key, value|
        if key == :link
          %{#{indent}  <#{key} href="#{value}" />}
        else
          if value.is_a?(Bag)
            value.to_s(indent + '  ')
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

puts atom.to_atom
=end

module Feed::Atom
  STRFTIME = "%Y-%m-%d"

  class AtomBag < Feed::Bag
    def to_atom
      [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<feed xmlns="http://www.w3.org/2005/Atom">',
        to_s('  '),
        '</feed>',
      ]
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

module Feed::RSS_2_0
  STRFTIME = "%Y-%m-%d"

  class RSSBag < Feed::Bag
    def to_rss
      [
        '<?xml version="1.0"?>',
        '<rss version="2.0">',
        to_s('  '),
        '</rss>',
      ]
    end
  end

  class Feed < RSSBag; end
  class Item < RSSBag; end
  class Channel < RSSBag; end
end
