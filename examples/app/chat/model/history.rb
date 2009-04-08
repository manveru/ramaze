require 'ramaze/gestalt'

class History
  def initialize(size = 13)
    @size = size
    @history = []
  end

  def write(nick, text)
    text.strip!
    return if text.empty?
    @history.shift until @history.size < @size
    @history << Message.new(nick, text, Time.now)
    true
  end

  def to_html
    g = Ramaze::Gestalt.new

    each do |message|
      g.div(:class => :message) do
        g.span(:class => :time){ message[:time].strftime('%X') }
        g.span(:class => :nick){ message[:nick] }
        g.span(:class => :text){ message[:text] }
      end
    end

    g.to_s
  end

  include Enumerable

  def each
    @history.sort.each do |message|
      yield message
    end
  end
end
