#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Controller

  helper :aspect

  def index
    @tasks = []
    TodoList.original.each do |title, parameters|
      if parameters[:done]
        status = 'done'
        toggle = link( Rs(:open, escape(title) ), :title => 'Open Task' )
      else
        status = 'not done'
        toggle = link( Rs(:close, escape(title) ), :title => 'Close Task' )
      end
      delete = link( Rs(:delete, escape(title) ), :title => 'Delete' )
      @tasks << [title, status, toggle, delete]
    end
    @tasks.sort!
  end

  def create
    if title = request['title']
      title.strip!
      if title.empty?
        error("Please enter a title")
        redirect '/new'
      end
      TodoList[title] = {:done => false}
    end
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

  after(:create, :open, :close, :delete){ redirect_index }

  def redirect_index
    redirect(Rs())
  end

  private

  def error(message)
    flash[:error] = message
  end

  def task_status title, status
    unless task = TodoList[title]
      error "No such Task: `#{title}'"
      redirect_referer
    end

    task[:done] = status
    TodoList[title] = task
  end
end
