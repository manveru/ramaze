class MainController < Ramaze::Controller
  def index handle = "main"
    @handle = handle
    @entry = WikiEntry.new(handle)
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

  def edit handle
    @handle = handle
    @entry = WikiEntry[handle]
    @text = @entry.content
  end

  def revert handle
    WikiEntry[handle].revert
    redirect Rs(handle)
  end

  def unrevert handle
    WikiEntry[handle].unrevert
    redirect Rs(handle)
  end

  def save
    redirect_referer unless request.post?
    handle = request['handle']
    entry = WikiEntry[handle]
    entry.save(request['text'])
    redirect Rs(:index, handle)
  end
end
