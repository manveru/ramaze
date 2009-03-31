module TodoList
  class Controller < Ramaze::Controller
    layout :default
    engine :Etanni
    helper :form
    trait :app => :todolist
  end
end

require 'controller/task'
