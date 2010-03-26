require File.expand_path('../../../spec/helper', __FILE__)
require File.expand_path('../../../examples/app/todolist/start', __FILE__)

TodoList::Task.create(:title => 'do the dishes')
TodoList::Task.create(:title => 'build an awesome Ramaze app')

describe "Todolist app example" do
  behaves_like :rack_test
  
  it "should list tasks" do
    r = get('/').body
    r.should.include('do the dishes')
    r.should.include('build an awesome Ramaze app')
  end
  
  it "should close a task" do
    get('/close/do+the+dishes')
    r = get('/').body
    r.should.include('<td class="status"> Done </td>')
  end
  
  it "should delete a task" do
    get('/delete/build+an+awesome+Ramaze+app')
    r = get('/').body
    r.should.not.include("build an awesome Ramaze app")
  end
  
  it "should open a task" do
    get('/open/do+the+dishes')
    r = get('/').body
    r.should.include('<td class="status"> Pending </td>')
  end
end
