class MainController < Controller
  def index
    @entries = Entry.all :order => 'created DESC'
  end
  def delete oid
    Entry.delete oid
    redirect :/
  end
  def edit oid
    @entry = Entry[oid]
  end
  def create
    Entry.create request['title'], request['content']
    redirect :/
  end
  def save
    redirect_referer unless oid = request['oid']
    entry = Entry[oid]
    entry.title = request['title']
    entry.content = request['content']
    entry.updated = Time.now
    entry.save
    redirect :/
  end
end
