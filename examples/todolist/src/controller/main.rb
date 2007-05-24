#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Controller

  helper :aspect

  def index
    @tasks = []
    TodoList.original.each do |title, parameters|
      if parameters[:done]
        status = 'done'
        toggle = link( Rs(:open, title ), :title => 'Open Task' )
      else
        status = 'not done'
        toggle = link( Rs(:close, title ), :title => 'Close Task' )
      end
      delete = link( Rs(:delete, title ), :title => 'Delete' )
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
  end

  def close title
    task_status title, true
  end

  def delete title
    TodoList.delete title
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
