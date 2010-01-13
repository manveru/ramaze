class MainController < Ramaze::Controller
  layout :application
  before_all {setup}

  def index(handle = "main")
    @entry = WikiEntry.new(handle)
    @handle = @entry.name

    if @entry.exists?
      @text = EntryView.render(@entry.content)
      @history = @entry.history.map{|f|
        DateTime.strptime(File.basename(f, ".mkd"),
        "%Y-%m-%d_%H-%M-%S")
      }.join("<br />\n")
    else
      @text = "No Entry"
    end
  end

  def edit(handle)
    @entry = WikiEntry.new(handle)
    @handle = @entry.name
    @text = @entry.content
  end

  def revert(handle)
    WikiEntry[handle].revert
    redirect route(handle)
  end

  def unrevert(handle)
    WikiEntry[handle].unrevert
    redirect route(handle)
  end

  def delete(handle)
    WikiEntry.new(handle).delete
    redirect_referer
  end

  def save
    redirect_referer unless request.post?

    handle = request['handle']
    entry = WikiEntry.new(handle)
    entry.save(request['text'])
    redirect entry.route
  end

  def setup
    @nodes = WikiEntry.titles.map{|f|
      anchor File.basename(f)
    }.join("\n")
  end
end
