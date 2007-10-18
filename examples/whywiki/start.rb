#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# written as an example of how to implement the minimal _why wiki

require 'ramaze'
require 'bluecloth'

Db = Ramaze::YAMLStoreCache.new('wiki.yaml') unless defined?(Db)

class WikiController < Ramaze::Controller
  map :/
  engine :Nagoro

  def index
    redirect R(:show, 'Home')
  end

  def show page = 'Home'
    @page = url_decode(page)
    @text = Db[page].to_s
    @edit_link = "/edit/#{page}"

    @text.gsub!(/\[\[(.*?)\]\]/) do |m|
      exists = Db[$1] ? 'exists' : 'nonexists'
      A($1, :href => Rs(:show, url_encode($1)), :class => exists)
    end

    @text = BlueCloth.new(@text).to_html
  end

  def edit page = 'Home'
    @page = url_decode(page)
    @text = Db[page]
  end

  def save
    redirect_referer unless request.post?

    page = request['page'].to_s
    text = request['text'].to_s

    Db[page] = text

    redirect Rs(:show, url_encode(page))
  end
end

Ramaze.start :adapter => :mongrel
