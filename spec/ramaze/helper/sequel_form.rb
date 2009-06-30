#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)

spec_requires 'hpricot', 'sequel'

DB = Sequel.sqlite

class User < Sequel::Model(:user)
  plugin :schema

  set_schema do
    primary_key :id

    boolean :online
    varchar :name
    integer :level
    text :description
    date :birthday
    time :created
  end

  create_table unless table_exists?
end

class FormController < Ramaze::Controller
  map '/'
  helper :sequel_form

  def new
    sequel_form(User).to_s
  end

  def new_with_options
    sequel_form(User, :method => :post, :action => r(:create)).to_s
  end

  def edit(id)
    sequel_form(User[id]).to_s
  end

  def edit_with_options(id)
    sequel_form(User[id], :method => :post, :action => r(:create)).to_s
  end
end

describe Ramaze::Helper::SequelForm do
  behaves_like :rack_test

  def hget(uri)
    got = get(uri)
    got.status.should == 200
    Hpricot(got.body)
  end

  it 'provides forms for model class' do
    form = hget('/new').at(:form)
    (form/:input).size.should == 5
    (form/:input).map{|i| i[:name] }.compact.sort.should == %w[level name online]
    form.at(:textarea)[:name].should == 'description'
  end

  it 'provides form for model class with options' do
    form = hget('/new_with_options').at(:form)
    form.raw_attributes.should == {'action' => '/create', 'method' => 'post'}
  end

  data = {
    :name        => 'manveru',
    :description => 'Ramaze dev',
    :online      => true,
    :level       => 2,
    :birthday    => Time.now,
    :created     => Time.now,
  }
  User.create(data)

  it 'provides form for instance of model' do
    form = hget('/edit/1').at(:form)
    form.at('input[@name=name]').raw_attributes.should ==
      { 'name' => 'name', 'type' => 'text', 'value' => data[:name] }
    form.at('input[@name=online]').raw_attributes.should ==
      { "name" => "online", "type" => "checkbox", "checked" => "checked",
        "value" => data[:online].to_s }
    form.at('input[@name=level]').raw_attributes.should ==
      { "name" => "level", "type" => "text", "value" => data[:level].to_s }
  end

  it 'provides form with options for instance of model' do
    hget('/edit_with_options/1').at(:form).raw_attributes.should ==
      {"action" => "/create", "method" => "post"}
  end
end
