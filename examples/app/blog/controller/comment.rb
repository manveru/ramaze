module Blog
  class Comments < Controller
    map '/comment'
    helper :gravatar

    def index(id)
    end

    def show
      @pub_formatted = @comment.published.strftime(Blog.options.time_format)
      @id = @comment.id
      @author = h(@comment.author)
      @homepage = @comment.homepage
      @content = h(@comment.content)
      @href = @comment.href
      @gravatar = gravatar(@comment.email.to_s, :size => 80, :default => :wavatar)
    end

    def create
      @comment = Comment.new
      @entry = Entry[request[:entry_id]]

      if @comment.update(@entry, request)
        redirect @comment.href
      else
        render_partial(:form, :comment => @comment, :entry => @entry)
      end
    end

    def form
      @comment ||= Comment.new
      form_errors_from_model(@comment)
    end

    def edit(id)
      'TODO: not implemted'
    end

    def delete(id)
      login_required
      Comment[id].destroy
      redirect_referrer
    end
  end
end
