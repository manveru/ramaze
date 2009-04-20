module Blog
  class EntriesTags < Sequel::Model
    set_schema do
      primary_key :id

      foreign_key :entry_id
      foreign_key :tag_id
    end

    many_to_one :entry, :class => 'Blog::Entry'
    many_to_one :tag, :class => 'Blog::Tag'

    create_table unless table_exists?
  end

  class Tag < Sequel::Model
    set_schema do
      primary_key :id

      varchar :name, :unique => true
    end

    many_to_many :entries, :class => 'Blog::Entry'

    def to_s
      name
    end

    def <=>(other)
      raise ArgumentError unless other.respond_to?(:name)
      self.name <=> other.name
    end

    create_table unless table_exists?
  end
end
