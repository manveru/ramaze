#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Controller

  trait :engine => Template::Ezamar

  def index
    @tasks = []
    TodoList.original.each do |title, parameters|
      if parameters[:done]
        status = 'done'
        toggle = link( R( self, :open, CGI.escape(title) ), :title => 'Open Task' )
      else
        status = 'not done'
        toggle = link( R( self, :close, CGI.escape(title) ), :title => 'Close Task' )
      end
      delete = link( R( self, :delete, CGI.escape(title) ), :title => 'Delete' )
      @tasks << [title, status, toggle, delete]
    end
    @tasks.sort!
  end

  def create
    title = request['title']
    TodoList[title] = {:done => false}
    redirect R(self)
  end

  def open title
    task_status title, false
    redirect R(self)
  end

  def close title
    task_status title, true
    redirect R(self)
  end

  def delete title
    TodoList.delete title
    redirect R(self)
  end

  def error
    @foo = 'bar'
  end

  private

  def task_status title, status
    task = TodoList[title]
    task[:done] = status
    TodoList[title] = task
  end
end
