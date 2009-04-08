module Blog
  class Entries < Controller
    map '/entry'
    provide(:rss, :type => 'application/rss+xml', :engine => :Nagoro)
    provide(:atom, :type => 'application/atom+xml', :engine => :Nagoro)

    def index(slug)
      @entry = Entry.from_slug(slug)
      redirect Blog::Main.r('/') unless @entry
      @tabindex = 10 # outsmart the sidebar tabindex for login
    end

    # just making the work in the template easier
    def show
      @id = @entry.id
      @href = @entry.href
      @comment_href = @entry.comment_href
      @respond_href = @entry.respond_href
      @trackback_href = @entry.trackback_href

      @title = h(@entry.title)
      @pub_iso = @entry.published.iso8601
      @pub_formatted = @entry.published.strftime(Blog.options.time_format)

      @comment_count = number_counter(@entry.comments.count, 'comment')
    end

    def feed
    end

    def edit(slug)
      login_required
      @entry = Entry.from_slug(slug)
      @tags = fetch_tags
    end

    def save
      login_required
      @entry = Entry[request[:id]]
      @entry.update(request)

      redirect @entry.href
    end

    def new
      login_required
      @entry = Entry.new
      @tags = fetch_tags
    end

    def create
      login_required
      @entry = Entry.new
      @entry.update(request)

      redirect @entry.href
    end

    def delete(slug)
      login_required
      Entry.from_slug(slug).destroy
    end

    private

    def fetch_tags
      if tags = request[:tags]
        tags.scan(/\S+/).join(' ')
      elsif @entry.id and tags = @entry.tags
        tags.join(' ')
      else
        ''
      end
    end
  end
end
