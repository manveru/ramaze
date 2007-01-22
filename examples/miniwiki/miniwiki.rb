#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# written as an example of how to implement the minimal _why wiki

begin
require 'rubygems'
rescue LoadError
end

require 'ramaze'
require 'bluecloth'

require 'yaml/store'

Db = YAML::Store.new('wiki.yaml')

include Ramaze

class WikiController < Template::Ramaze
  def index
    show 'Home'
  end

  def show page = 'Home'
    text = Db.transaction{ Db[page] }.to_s

    Gestalt.new do
      a(:href => '/'){'< Home'} unless page == 'Home'
      h1{ page }

      if text.empty?
        a(:href => "/edit/#{page}"){'Create?'}
      else
        div do
          a(:href => "/edit/#{page}"){"Edit #{page}"}
          BlueCloth.new(
                        text.gsub(/\[\[(.*?)\]\]/, '<a href="show/\1">\1</a>')
                       ).to_html
        end
      end
    end
  end

  def edit page = 'Home'
    Gestalt.new{
      h1{ "Edit #{page}" }
      a(:href => "/show/#{page}"){"Show #{page}"}
      form(:method => :post, :action => '/save') do
        input :type => :hidden, :name => :page, :value => page
        textarea(:name => :text, :style => 'width: 90%; height: 200px') do 
          Db.transaction{ Db[page] }.to_s
        end
        input :type => :submit
      end
      }.to_s
  end

  def save
    Db.transaction{ Db[request['page']] = CGI.unescape(request['text'] || '') }
    redirect "/show/#{request['page']}"
  end
end


#Global.adapter = :webrick
#Global.tidy = true
Global.mode = :benchmark
Global.mapping = {'/' => WikiController}

start
