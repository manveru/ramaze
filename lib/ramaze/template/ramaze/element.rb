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
      def transform string = '', binding = nil
        string = string.to_s
        matches = string.scan(/<([A-Z][a-zA-Z0-9]*)(.*?)?>/)
        matches.each do |(klass, params)|
          next unless klass and string =~ /<\/#{klass}>/
          string.gsub!(/<#{klass}( .*?)?>(.*?)<\/#{klass}>/m) do |m|
            hash = demunge_passed_variables($1.to_s)
            k = constant(klass).new($2) rescue nil

            break m unless k and k.respond_to?(:render)

            case k.method(:render).arity
            when 0 : k.render
            else
              k.render(hash)
            end
          end
        end
        string
      end

      # very buggy and not reliable, but for my usual purposes it's good enough :)
      def demunge_passed_variables(string)
        string.scan(/\s?(.*?)="(.*?)"/).inject({}) do |hash, (key, value)|
          hash.merge key => value
        end
      end
    end
  end
end
