module Blog
  class Comments < Controller
    map '/comment'

    def show(id)
      @comment = Comment[id]
    end

    def create
      @comment = Comment.new
      @comment.update(request)

      redirect @comment.href
    end

    def form
    end
  end
end
