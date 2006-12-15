#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Element
    extend Ramaze::Helper

    helper :link, :redirect

    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def render *args
      @content
    end

    class << self
      def transform string = ''
        string = string.to_s
        matches = string.scan(/<\/?[A-Z][a-zA-Z0-9]*>/)
        matches.each do |match|
          klass = match.match(/<\/(.*?)>/).to_a.last
          next unless klass and matches.include?("<#{klass}>")
          string.gsub!(/<#{klass}( .*?)?>(.*?)<\/#{klass}>/m) do
            k = constant(klass).new($2)
            case k.method(:render).arity
            when 0 : k.render
            else
              k.render($1)
            end
          end
        end
        string
      end
    end
  end
end
