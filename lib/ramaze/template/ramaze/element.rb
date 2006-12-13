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

    def render
      @content
    end
  end
end


