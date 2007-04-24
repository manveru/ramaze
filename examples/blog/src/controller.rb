#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Controller
  helper :form, :auth, :aspect

  trait :auth_table => {'manveru' => Digest::SHA1.hexdigest('password')}

  def index
    @title = 'Ramaze Blog'
    @entries = Entry.keys.reverse.map{|k| Entry[k]}
  end

  def view eid
    @entry = Entry[eid]
  end

  def new
    @title = "Add Entry"
  end

  def add
    entry = Entry.new.merge!(request.params)
    entry.time = Time.now
    session[:result] = "<em>#{entry.title}</em> added successfully" if entry.save
    redirect :/
  end

  def edit eid
    @entry = Entry[eid]
  end

  def save
    redirect_referer unless eid = request.params.delete('eid')
    entry = Entry[eid].merge!(request.params)
    session[:result] = "<em>#{entry.title}</em> saved successfully" if entry.save
    redirect :/
  end

  def delete eid
    if entry = Entry[eid]
      if entry.delete
        session[:result] = "<em>#{entry.title}</em> deleted successfully"
      else
        session[:result] = "Couldn't delete <em>#{entry.title}</em>"
      end
    end
    redirect_referer
  end

  pre :all, :logged_in?, :except => [:index, :view]
end
