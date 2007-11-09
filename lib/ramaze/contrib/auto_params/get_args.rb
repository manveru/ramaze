# from merb/core_ext/get_args.rb
begin
  require 'ruby2ruby'

  class ParseTreeArray < Array
    def self.translate(*args)
      self.new(ParseTree.translate(*args))
    end

    def deep_array_node(type = nil)
      each do |node|
        return ParseTreeArray.new(node) if node.is_a?(Array) && (!type || node[0] == type)
        next unless node.is_a?(Array)
        return ParseTreeArray.new(node).deep_array_node(type)
      end
      nil
    end

    def arg_nodes
      self[1..-1].inject([]) do |sum,item|
        sum << [item] unless item.is_a?(Array)
        sum
      end
    end

    def get_args
      arg_node = deep_array_node(:args)
      args = arg_node.arg_nodes
      lasgns = arg_node.deep_array_node(:block)[1..-1]
      lasgns.each do |asgn|
        args.assoc(asgn[1]) << eval(RubyToRuby.new.process(asgn[2]))
      end
      args
    end

  end

  module GetArgs
    def get_args
      klass, meth = self.to_s.split(/ /).to_a[1][0..-2].split("#")
      klass = $` if klass =~ /\(/
      ParseTreeArray.translate(Object.const_get(klass), meth).get_args
    end
  end

  class UnboundMethod
    include GetArgs
  end

  class Method
    include GetArgs
  end
rescue LoadError
end