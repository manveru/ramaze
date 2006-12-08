#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Template::Ramaze
  def index
    @title = 'Blogging Ramaze'
    @entries = Entry.all
  end
end

class EntryController < Template::Ramaze
  helper :form

  def index
    @entries = Entry.all
  end

  def view oid
    Entry[oid.to_i].pretty_insepct
  end

  def new
    @title = "Add Entry"
  end

  def add
    entry = Entry.new.assign(request.params)
    entry.save
    redirect :/
  end

  def delete oid
    entry.delete if entry = Entry[oid.to_i]
    redirect_referer
  end
end
