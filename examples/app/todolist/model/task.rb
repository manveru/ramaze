module TodoList
  class Task < Sequel::Model
    set_schema do
      primary_key :id

      varchar :title, :unique => true, :empty => false
      boolean :done, :default => false
    end

    create_table unless table_exists?

    def href(action)
      Tasks.r(action, Ramaze::Helper::CGI.url_encode(title))
    end

    def toggle_link
      action = done ? 'open' : 'close'
      Tasks.a(action, href(action))
    end

    def delete_link
      Tasks.a('delete', href('delete'))
    end

    def status
      done ? 'done' : 'pending'
    end

    def close!
      self.done = true
      save
    end

    def open!
      self.done = false
      save
    end
  end
end
