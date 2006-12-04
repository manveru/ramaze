class MainController < Template::Ramaze
  def index
    @title = 'Blogging Ramaze'
    @entries = [
      %{ Day one, still very flakey, but this is how it will work :) },
    ]
    nil
  end
end

class EntryController < Template::Ramaze
  helper :link

  def index
    @entries = Entry.all.pretty_inspect
  end

  def view oid
    Entry[oid.to_i].pretty_insepct
  end

  def new
    redirect :entry, :old, 1
  end

  def add
  end
end
