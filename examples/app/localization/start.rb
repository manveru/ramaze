# -*- coding: utf-8 -*-
require 'rubygems'
require 'ramaze'

# require YAML based localization
require 'ramaze/helper/localize'

#
# Old Dispatcher::Action::FILTER style localization.
#
class MainController < Ramaze::Controller
  helper :localize

  def index
    # Enclose the strings that have to be localized with {}
    "<h1>{hello world}</h1>
     <p>{just for fun}</p>
     <a href='/locale/en'>{english}</a><br />
     <a href='/locale/ja'>{japanese}</a><br />
     <a href='/locale/de'>{german}</a><br />
    "
  end

  def locale(name)
    session[:lang] = name
    redirect r(:/)
  end

  # for Localization
  alias :raw_wrap_action_call :wrap_action_call

  def wrap_action_call(action, &block)
    localize(raw_wrap_action_call(action, &block))
  end

  private

  Dictionary = Ramaze::Helper::Localize::Dictionary.new
  Dir.glob('./locale/*.yaml').each do |path|
    Dictionary.load(File.basename(path, '.yaml').intern, :yaml => path)
  end

  def localize_dictionary
    Dictionary
  end
end

Ramaze.start
