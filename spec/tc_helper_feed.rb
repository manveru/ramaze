#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

begin
  require 'hpricot'
rescue LoadError
  exit
end

require 'ramaze/helper/feed'
require 'pp'

class String
  def hpricot
    Hpricot(self)
  end
end

class With
  class << self
    def with(hash)
      instance = self.new
      hash.each do |key, value|
        instance.send("#{key}=", value)
      end
      instance
    end
  end
end

include Ramaze

class Book < With
  include ReFeed

  attr_accessor :title, :text, :author, :isbn, :description

  xml :title, :text, :type => :text
  xml :isbn, :type => :attribute
  xml :description, :type => :cdata
  xml :author
end

class User < With
  include ReFeed

  xml_accessor :name, :email, :type => :text
  xml_accessor :books
end

context "ReFeed" do
  context "User" do
    user = User.with :name => 'manveru', :email => 'foo@bar.com'

    specify "to_xml" do
      xml = ( user.to_xml.hpricot/:user )

      xml.size.should == 1
      xml.at('email').inner_html.should == user.email
      xml.at('name').inner_html.should  == user.name
    end
  end

  context "Book" do
    book = Book.with :title => 'foo', :text => 'bar',
                     :isbn => 123456789012, :description => 'The Best Foo in the world!'

    specify "to_xml" do
      xml = ( book.to_xml.hpricot/:book )

      xml.size.should == 1

      xml.first['isbn'].to_i.should == book.isbn

      xml.at('description').inner_html.should == book.description
      xml.at('title').inner_html.should       == 'foo'
      xml.at('text').inner_html.should        == 'bar'
    end
  end

  context "Book and User" do
    user = User.with :name => 'manveru', :email => 'foo@bar.com'
    book = Book.with :title => 'foo', :text => 'bar', :author => user

    specify "to_xml" do
      xml_book = ( book.to_xml.hpricot/:book )
      xml_user = xml_book.at(:user)

      xml_book.at('title').inner_html.should == book.title
      xml_book.at('text').inner_html.should  == book.text

      xml_user.at('name').inner_html.should  == user.name
      xml_user.at('email').inner_html.should == user.email
    end
  end

  context "User and books" do
    book1  = Book.with :title => 'foo', :text => 'bar'
    book2  = Book.with :title => 'foz', :text => 'baz'
    user      = User.with :name => 'manveru', :email => 'foo@bar.com',
    :books => [book1, book2]

    specify "to_xml" do
      xml       = ( user.to_xml.hpricot/:user )
      books  = ( xml/:book )
      first     = books.find{|a| a.at('title').inner_html == book1.title }
      second    = books.find{|a| a.at('title').inner_html == book2.title }

      books.size.should == 2

      xml.at('name').inner_html.should      == user.name
      xml.at('email').inner_html.should     == user.email

      first.at('title').inner_html.should   == book1.title
      first.at('text').inner_html.should    == book1.text

      second.at('title').inner_html.should  == book2.title
      second.at('text').inner_html.should   == book2.text
    end
  end

  context "User from XML" do
    user = User.with :name => 'manveru', :email => 'foo@bar.com'

    specify "from_xml" do
      new_user = User.from_xml(user.to_xml)
      new_user.name.should == user.name
      new_user.email.should == user.email
    end
  end
end
