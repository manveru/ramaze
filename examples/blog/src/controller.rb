#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Template::Ramaze
  def index
    @entries = Entry.all.reverse
  end
end

class EntryController < Template::Ramaze
  helper :form

  def index
    @entries = Entry.all.reverse
  end

  def view oid
    @entry = Entry[oid.to_i]
  end

  def new
    @title = "Add Entry"
  end

  def add
    entry = Entry.new.assign(request.params)
    session[:result] = "#{entry.title} added successfully" if entry.save
    redirect :/
  end

  def edit oid
    @entry = Entry[oid.to_i]
  end

  def save
    redirect_referer unless oid = request.params.delete('oid').to_i
    entry = Entry[oid].assign(request.params)
    session[:result] = "#{entry.title} saved successfully" if entry.save
    redirect :/
  end

  def delete oid
    if entry = Entry[oid.to_i]
      if entry.delete
        session[:result] = "#{entry.title} deleted successfully"
      else
        session[:result] = "Couldn't delete #{entry.title}"
      end
    end
    redirect_referer
  end
end
