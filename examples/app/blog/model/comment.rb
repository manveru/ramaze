module Blog
  class Comment < Sequel::Model
    set_schema do
      primary_key :id

      time :published
      time :updated
      boolean :public, :default => true
      varchar :author
      varchar :email
      varchar :homepage
      text :content

      foreign_key :entry_id
    end

    many_to_one :entry, :class => 'Blog::Entry'

    before_save{ self.updated = Time.now }
    before_create{ self.published = Time.now }

    create_table unless table_exists?

    def href
      Entries.r(:/, "#{entry.slug}#comment-#{id}")
    end

    def update(hash)
      self.author = hash[:author]
      self.content = hash[:content]
      self.homepage = hash[:homepage]
      save
      Entry[hash[:entry_id]].add_comment(self)
      self
    end
  end
end
