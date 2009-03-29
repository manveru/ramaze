module TodoList
  class Tasks < Controller
    map '/'

    def index
      @tasks = Task.all
      @title = request[:title]
    end

    def create
      title = request[:title]
      redirect r('/', :title => title) unless request.post? and title
      Task.create(:title => title)
      redirect r('/')
    rescue Sequel::DatabaseError => ex
      flash[:error] = ex.message
      redirect r('/', :title => title)
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
