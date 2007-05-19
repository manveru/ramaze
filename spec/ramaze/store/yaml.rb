#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/store/yaml'

describe "Store::YAML" do
  def new_store name
    Ramaze::Store::YAML.new(name, :destroy => true)
  end

  after :all do
    FileUtils.rm('article.yaml')
    FileUtils.rm('author.yaml')
  end

  it "model" do
    article_class = new_store :article
    article_class.entities.should_not == nil
  end

  it "store and retrieve" do
    article_class = new_store :article
    article = article_class.new
    article.title = 'the article'
    article.text  = 'the articles text'
    article.eid.should == nil
    article.save

    article.eid.should == 'a'

    old_article = article_class[article.eid]
    old_article.title.should == article.title
    old_article.text.should == article.text
  end

  it "convenience" do
    article_class = new_store :article
    article_class.all.should be_empty
    article = article_class.new
    article.name = 'the article'
    article.save

    article_class.keys.should == [:a]
    article_class.all.should_not be_empty
  end

  it "relations" do
    article_class = new_store :article
    author_class  = new_store :author

    author = author_class.new
    author.name = 'manveru'

    article = article_class.new
    article.name = 'the article'
    article.author = author
    article.save

    article = article_class[article.eid]
    article.author.name.should == author.name
    author.article.name.should == article.name
  end

  it "delete" do
    article_class = new_store :article

    article = article_class['foo'] = {
      :bar => :one
    }

    article_class['foo'].should == {:bar => :one}
    article_class.delete 'foo'
    article_class['foo'].should == nil
  end
end
