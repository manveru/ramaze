module Blog
  class Tags < Controller
    map '/tag'

    def index(*tags)
      @tags = Tag.filter(:name => tags).eager(:entries)
    end
  end
end
