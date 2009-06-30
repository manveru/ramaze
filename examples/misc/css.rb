require 'rubygems'
require 'ramaze'

# delete cached css after inline template is changed
module Ramaze::SourceReloadHooks
  module_function
  def after_safe_load file
    Ramaze::Cache.actions.delete '/css/style.css' if file == __FILE__
  end
end

class CSSController < Ramaze::Controller
  helper :cache
  provide :css, :type => 'text/css', :engine => :Sass

  def style
    %(
body
  font:
    family: sans-serif
    size: 11px
  margin: 0.5em
  padding: 1em
    )
  end

  cache_action :method => 'style'
end

# http://localhost:7000/css/style.css
Ramaze.start :adapter => :mongrel, :port => 7000
