#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'
require 'ramaze/store/yaml'

context "Store::YAML" do
  def new_store name
    Ramaze::Store::YAML.new(name, :destroy => true)
  end

  specify "model" do
    article_class = new_store :article
    article_class.entities.should_not == nil
  end

  specify "store and retrieve" do
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

  specify "relations" do
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
end
