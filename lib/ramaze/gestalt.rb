class BlankSlate
  alias __instance_eval__ instance_eval
  alias __instance_variable_set__ instance_variable_set
  instance_methods.each{|m| undef_method m unless m =~ /^__/}
end

=begin rdoc
Example:

  require 'ramaze'
  require 'ramaze/gestalt'

  def random_color
    r = lambda{|n| rand(n).to_s(16) }
    '#' + [255, 255, 255].map{r[255] + r[255] + r[255]
  end

  puts Ramaze::Gestalt.build{
    html do
      head do
        title{"Hello World"}
      end
      body do
        h1{"Hello, World!"}
        div(:style => 'width:100%') do
          10.times do
            div(:style => "width:#{rand(100)}%;height:#{rand(100)}%;background:#{random_color}"){ '&nbsp;' }
          end
        end
      end
    end
  }
=end

module Ramaze
  class Gestalt < BlankSlate
    def self.build &block
      self.new(&block).to_s
    end

    def initialize &block
      @out = ''
      __instance_eval__(&block) if block_given?
    end

    # proxy everything to _gestalt_handle
    def method_missing meth, *args, &block
      _gestalt_handle meth, *args, &block
    end

    # A little hack to circumvent Kernel::p
    def p *args, &block
      _gestalt_handle :p, *args, &block
    end

    def _gestalt_handle meth, *args, &block
      _gestalt_build_tag(meth, *args, &block)
    end

    # build a tag for `name`, using `args` and an optional block that 
    # will be yielded
    def _gestalt_build_tag(name, args = [])
      @out << "<#{name}"
      if block_given?
        @out << args.inject(''){ |s,v| s << %{ #{v[0]}="#{v[1]}"} }
        @out << ">"
        text = yield
        @out << text if text != @out and text.respond_to?(:to_str)
        @out << "</#{name}>"
      else
        @out << args.inject(''){ |s,v| s << %{ #{v[0]}="#{v[1]}"} }
        @out << ' />'
      end
    end

    def to_s
      @out.to_s
    end
  end
end
