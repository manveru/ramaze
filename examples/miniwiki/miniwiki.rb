require 'rubygems'
require 'ramaze'
require 'bluecloth'

require 'yaml'

module Kernel
  def ivs
    instance_variables.inject({}){|s,v| s.merge v => eval(v)}
  end
end

include Ramaze

class Page < Gestalt
  def self.transform template = '', ivs = ivs
    self.new do
      ivs.each{ |k, v| __instance_variable_set__(k, v) }
      __instance_eval__(template)
    end
  end
end

class Database
  def initialize file = 'db.yaml'
    @file = file
    load
  end

  def load file = @file
    @db = YAML.load_file(file)
    p [:loaded, @db]
  end

  def save file = @file
    File.open(file, 'w+') do |f|
      f.print(YAML.dump(@db))
    end
    p [:saved, @db]
  end

  def method_missing(meth, *params, &block)
    p [:method_missing, meth, params]
    @db.send(meth, *params, &block)
  end
end

class MainController < Template::Ramaze
  def index title = 'miniwiki'
    @title = title
    @text = BlueCloth.new(database[title]).to_html
    render(:index)
  end

  def edit title
    @title = title
    if @text = database[@title]
      render(:edit)
    else
      redirect :index
    end
  end

  def save
    title, text = request.params.values_at('title', 'text')
    database[title] = text
    database.save
    redirect :index
  end

  def render template
    Page.transform(File.read("template/#{template}.rmze"), ivs)
  end

  def redirect target
    Gestalt.new{html{body{a(:href => "/#{target}"){target.to_s}}}}
  end

  def database
    @database ||= Database.new('db.yaml')
  end
end

Global.adapter = :webrick
Global.tidy = true

start
