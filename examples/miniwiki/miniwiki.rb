require 'ramaze'

include Ramaze

class Gestalt
  def page stitle
    html do
      head do
        title do
          stitle
        end
      end
      body do
        yield
      end
    end
  end
end

class MainController < Template::Ramaze
  def index
    Gestalt.new{
      page('index') do
        h1 do
          "Hello World"
        end
      end
    }.to_s
  end
end

start
