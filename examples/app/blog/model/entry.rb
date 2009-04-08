module Blog
  class Entry < Sequel::Model
    set_schema do
      primary_key :id

      time :published
      time :updated
      text :content
      varchar :title
      boolean :allow_comments, :default => true
    end

    many_to_many :tags, :class => 'Blog::Tag'
    one_to_many :comments, :class => 'Blog::Comment'

    before_save{ self.updated = Time.now }
    before_create{ self.published = Time.now }

    def self.from_slug(slug)
      self[slug[/\d+/]]
    end

    def self.history(limit)
      order(:published.desc).first(limit)
    end

    def update(hash)
      self.title = hash[:title]
      self.content = hash[:content]
      save
      self.tags = hash[:tags]
      self
    end

    def slug
      self.class.slug(id, title)
    end

    def href
      self.class.href(id, title)
    end

    def self.slug(id, title)
      Innate::Helper::CGI.u("#{id}-#{title.scan(/\w+/).join('-')}")
    end

    def self.href(id, title)
      Blog::Entries.r(:/, slug(id, title))
    end

    def trackback_href
      Blog::Entries.r(:trackback, slug)
    end

    def respond_href
      Blog::Entries.r(:/, "#{slug}#respond")
    end

    def comment_href
      Blog::Entries.r(:/, "#{slug}#comments")
    end

    def tags=(tags)
      remove_all_tags
      tags.to_s.downcase.scan(/[^\s,\.]+/).uniq.each{|tag|
        add_tag(Tag.find_or_create(:name => tag))
      }
    end

    def summary(size = 255)
      content[0..size]
    end

    def to_html(text = content)
      Maruku.new(text).to_html
    end

    create_table unless table_exists?

    if empty?
      Ramaze::Log.info 'Populating database with fake entries'

      entry = create(:title => 'Blog created',
                     :content => 'Exciting news today, first post on this blog')
      entry.add_tag(Tag.create(:name => 'ramaze'))
      entry.add_tag(Tag.create(:name => 'blog'))
    end
  end
end
