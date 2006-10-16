class BlankSlate
  alias __instance_eval__ instance_eval
  instance_methods.each{|m| undef_method m unless m =~ /^__/}
end

module Ramaze
  class Gestalt < BlankSlate
    def initialize &block
      @out = ''
      __instance_eval__(&block) if block_given?
    end

    def method_missing meth, *args, &block
      _gestalt_handle meth, *args, &block
    end

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
