module Blog
  class Main < Controller
    map '/'
    helper :paginate
    provide(:rss, :type => 'application/rss+xml', :engine => :Nagoro)
    provide(:atom, :type => 'application/atom+xml', :engine => :Nagoro)

    def index
      data = Entry.order(:published.desc)
      @pager = paginate(data, :limit => Blog.options.list_size)
    end

    def feed
      @entries = Entry.history(Blog.options.feed_size)
      @updated = @entries.last.updated
      @generator = 'Ramaze Blog 2009.03.24'
      @generator_uri = 'http://github.com/manveru/rablo'
    end
  end
end
