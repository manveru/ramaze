require 'sequel'
require 'sequel/sqlite'

case $wikore_db
when :memory
  DB = Sequel('sqlite:/')
else
  DB = Sequel('sqlite:///wikore.db')
end

module Model
  PAGE_SCHEMA = lambda{
  }

  class Page < Sequel::Model(:page)
    set_schema do
      primary_key :id
      text    :title, :unique => true, :null => false
      boolean :active, :default => true
      text    :text
      integer :version
    end

    def backup
      hash = @values.dup
      hash.delete :id
      OldPage.create(hash)
    end

    def revert
      backup = OldPage[:title => title].values.dup
      backup.delete :id
      delete
      self.class.create(backup)
    end
  end

  class OldPage < Sequel::Model(:old_page)
    set_schema do
      primary_key :id
      text    :title, :unique => false, :null => false
      boolean :active, :default => true
      text    :text
      integer :version
    end
  end

  [Page, OldPage].each do |klass|
    klass.create_table unless klass.table_exists?
  end
end
