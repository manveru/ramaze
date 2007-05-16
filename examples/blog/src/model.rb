class Entry
  property :created, Time
  property :updated, Time
  property :title, String
  property :content, String
  def initialize title, content
    @created=Time.now
    @updated=Time.now
    @title=title
    @content=content
  end
end
