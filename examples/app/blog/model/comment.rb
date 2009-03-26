module Blog
  class Comment < Sequel::Model
    set_schema do
      primary_key :id

      # on update
      varchar :author
      varchar :email
      varchar :homepage
      text :content

      # system
      time :published
      time :updated
      boolean :public, :default => true

      foreign_key :entry_id
    end

    many_to_one :entry, :class => 'Blog::Entry'

    create_table unless table_exists?

    before_save{ self.updated = Time.now }
    before_create{ self.published = Time.now }

    validations.clear

    validates do
      length_of :author, :within => (2..255)
      # yay, reddit! we should rather set a minimum like:
      # "I, for one, welcome our new x overlords.".size
      length_of :content, :minimum => 2

      # a@b.c anyone know a domain like that?
      length_of :email, :within => (5..255)
      format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

      format_of :homepage, :with => /^https?:\/\/[^\s\/]+\.[^\s\/]+/
    end

    def href
      Entries.r(:/, "#{entry.slug}#comment-#{id}")
    end

    def update(entry, hash)
      return unless entry

      [:author, :email, :homepage, :content].each do |key|
        self[key] = hash[key]
      end

      return unless valid?
      save
      entry.add_comment(self)
    end
  end
end
