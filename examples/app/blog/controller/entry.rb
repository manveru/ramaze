module Blog
  class Entries < Controller
    map '/entry'
    provide(:rss, :type => 'application/rss+xml', :engine => :Nagoro)
    provide(:atom, :type => 'application/atom+xml', :engine => :Nagoro)

    def index(slug)
      @entry = Entry.from_slug(slug)
      @tabindex = 10
      redirect Blog::Main.r('/') unless @entry
    end

    def show
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
