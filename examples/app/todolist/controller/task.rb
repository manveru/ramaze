module TodoList
  class Tasks < Controller
    map '/'

    def index
      @tasks = Task.all
      @title = request[:title]
    end

    def create
      if request.post? and title = request[:title]
        title.strip!

        unless title.empty?
          Task.create :title => title
        end
      end

      redirect route('/', :title => title)
    rescue Sequel::DatabaseError => ex
      redirect route('/', :title => title)
    end

    def open(title)
      Task[:title => title].open!
      redirect r('/')
    end

    def close(title)
      Task[:title => title].close!
      redirect r('/')
    end

    def delete(title)
      Task[:title => title].destroy
      redirect r('/')
    end
  end
end
