#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# written as an example of how to implement the minimal _why wiki

require 'ramaze'
require 'bluecloth'

include Ramaze

Db = YAMLStoreCache.new('wiki.yaml')

class WikiController < Controller
  def index
    redirect(R(:show, 'Home'))
  end

  def show page = 'Home'
    @page = CGI.unescape(page)
    @text = Db[page].to_s

    @text.gsub!(/\[\[(.*?)\]\]/) do |m|
      exists = Db[$1] ? 'exists' : 'nonexists'
      link( R(self, :show, CGI.escape($1)), :title => $1, :class => exists)
    end

    @text = BlueCloth.new(@text).to_html
  end

  def edit page = 'Home'
    @page = CGI.unescape(page)
    @text = Db[page]
  end

  def save
    redirect_referer unless request.post?

    page = request['page'].to_s
    text = request['text'].to_s

    Db[page] = text

    redirect R(self, :show, CGI.escape(page))
  end
end

Global.adapter = :mongrel
#Global.tidy = true
Global.mapping = {'/' => WikiController}

Ramaze.start
