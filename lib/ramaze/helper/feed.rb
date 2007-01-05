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

require 'uuidtools'

module Feed
  class Bag
    undef_method :id

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
      "urn:uuid:#{UUID.timestamp_create.to_s}"
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
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <title>Liftoff News</title>
    <link>http://liftoff.msfc.nasa.gov/</link>
    <description>Liftoff to Space Exploration.</description>
    <language>en-us</language>
    <pubDate>Tue, 10 Jun 2003 04:00:00 GMT</pubDate>
    <lastBuildDate>Tue, 10 Jun 2003 09:41:01 GMT</lastBuildDate>
    <docs>http://blogs.law.harvard.edu/tech/rss</docs>
    <generator>Weblog Editor 2.0</generator>
    <managingEditor>editor@example.com</managingEditor>
    <webMaster>webmaster@example.com</webMaster>

    <item>
      <title>Star City</title>
      <link>http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp</link>
      <description>How do Americans get ready to work with Russians aboard the
      International Space Station? They take a crash course in culture, language
      and protocol at Russia's Star City.</description>
      <pubDate>Tue, 03 Jun 2003 09:39:21 GMT</pubDate>
      <guid>http://liftoff.msfc.nasa.gov/2003/06/03.html#item573</guid>
    </item>
  </channel>
</rss>
=end

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

=begin
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

 <title>Example Feed</title>
 <subtitle>A subtitle.</subtitle>
 <link href="http://example.org/"/>
 <updated>2003-12-13T18:30:02Z</updated>
 <author>
   <name>John Doe</name>
   <email>johndoe@example.com</email>
 </author>
 <id>urn:uuid:60a76c80-d399-11d9-b91C-0003939e0af6</id>

 <entry>
   <title>Atom-Powered Robots Run Amok</title>
   <link href="http://example.org/2003/12/13/atom03"/>
   <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
   <updated>2003-12-13T18:30:02Z</updated>
   <summary>Some text.</summary>
 </entry>
</feed>
=end
