require 'rubygems'
require 'ramaze'

# This is a small extension to the hello world example, showing how to use the
# <render> tag of Nagoro.
#
# Browse to /more and /even_more

class MainController < Ramaze::Controller
  provide :html => :nagoro

  def index
    "Hello, World!"
  end

  def more
    @tail = request[:tail] || 'the standard'
    'More of <render src="/index" /> #@tail'
  end

  def even_more
    '<render src="/more" tail="This is even more" />'
  end
end

Ramaze.start
