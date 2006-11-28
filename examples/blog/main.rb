require 'src/model'

require 'ramaze'
include Ramaze

class MainController < Template::Ramaze
  def index
    nil
  end
end

class EntryController < Template::Ramaze
end

Global.template_root = 'template'
Global.mapping = {
  '/' => MainController,
  '/entry' => EntryController,
}
