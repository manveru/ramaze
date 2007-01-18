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

class Article < With
  include ReFeed

  attr_accessor :title, :text, :author

  xml :title, :text, :author, :foo => :bar
end

class User < With
  include ReFeed

  xml_accessor :name, :email, :articles, :foo => :bar
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

  context "Article" do
    article = Article.with :title => 'foo', :text => 'bar'

    specify "to_xml" do
      xml = ( article.to_xml.hpricot/:article )

      xml.size.should == 1
      xml.at('title').inner_html.should == 'foo'
      xml.at('text').inner_html.should  == 'bar'
    end
  end

  context "Article and User" do
    user    = User.with :name => 'manveru', :email => 'foo@bar.com'
    article = Article.with :title => 'foo', :text => 'bar', :author => user

    specify "to_xml" do
      xml_article = ( article.to_xml.hpricot/:article )
      xml_user    = xml_article.at(:user)

      xml_article.at('title').inner_html.should == article.title
      xml_article.at('text').inner_html.should  == article.text

      xml_user.at('name').inner_html.should     == user.name
      xml_user.at('email').inner_html.should    == user.email
    end
  end

  context "User and articles" do
    article1  = Article.with :title => 'foo', :text => 'bar'
    article2  = Article.with :title => 'foz', :text => 'baz'
    user      = User.with :name => 'manveru', :email => 'foo@bar.com',
    :articles => [article1, article2]

    specify "to_xml" do
      xml       = ( user.to_xml.hpricot/:user )
      articles  = ( xml/:article )
      first     = articles.find{|a| a.at('title').inner_html == article1.title }
      second    = articles.find{|a| a.at('title').inner_html == article2.title }

      articles.size.should == 2

      xml.at('name').inner_html.should      == user.name
      xml.at('email').inner_html.should     == user.email

      first.at('title').inner_html.should   == article1.title
      first.at('text').inner_html.should    == article1.text

      second.at('title').inner_html.should  == article2.title
      second.at('text').inner_html.should   == article2.text
    end
  end
end
