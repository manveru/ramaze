require 'rubygems'
require 'ramaze'

class Message < Struct.new(:nick, :text, :time)
  include Comparable

  def <=>(other)
    time <=> other.time
  end
end

class History
  include Ramaze::Helper::CGI

  def initialize(size = 13)
    @size = size
    @history = []
  end

  def write(nick, text)
    @history.shift until @history.size < @size
    @history << Message.new(nick, text, Time.now)
    true
  end

  def to_html
    @history.map{|message|
      "<div class='message'>" +
        [:nick, :time, :text].map{|key|
        span_for(message, key)
      }.join("\n") + "</div>"
    }.join("\n")
  end

  def span_for(message, key)
    "<span class='#{key}'>#{h(message[key])}</span>"
  end
end

class MainController < Ramaze::Controller
  HISTORY = History.new

  layout '/layout'

  def index
    if request.post?
      session[:nick] = request[:nick]
      redirect Rs(:chat)
    end
  end

  def chat
    redirect Rs(:/) unless session[:nick]
  end

  def say
    if nick = session[:nick] and text = request['text']
      return if text.empty?
      HISTORY.write(nick, text)
    end
  end

  def listen
    HISTORY.to_html
  end

  [ "Hello, World!",
    "My name is manveru",
    "I welcome you to my realm",
    "The unique and most awesome examples/chat.rb!",
  ].each{|text| HISTORY.write('manveru', text) }
end

Ramaze.start :middleware => true, :adapter => :thin
