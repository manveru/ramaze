# works just like OpenStruct, but as a kind of Singleton
# stores all Information as class-variable

module Ramaze
  class Global
    @@table = {}

    class << self
      def initialize(hash=nil)
        if hash
          for k,v in hash
            @@table[k.to_sym] = v
            new_ostruct_member(k)
          end
        end
      end

      # Duplicate an OpenStruct object members. 
      def initialize_copy(orig)
        super
        @@table = @@table.dup
      end

      def marshal_dump
        @@table
      end
      def marshal_load(x)
        @@table = x
        @@table.each_key{|key| new_ostruct_member(key)}
      end

      def new_ostruct_member(name)
        name = name.to_sym
        unless self.respond_to?(name)
          meta = class << self; self; end
        meta.send(:define_method, name) { @@table[name] }
        meta.send(:define_method, :"#{name}=") { |x| @@table[name] = x }
      end
    end

    def method_missing(mid, *args) # :nodoc:
      mname = mid.id2name
      len = args.length
      if mname =~ /=$/
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
      if self.frozen?
        raise TypeError, "can't modify frozen #{self.class}", caller(1)
      end
      mname.chop!
      self.new_ostruct_member(mname)
      @@table[mname.intern] = args[0]
      elsif len == 0
        @@table[mid]
      else
        raise NoMethodError, "undefined method `#{mname}' for #{self}", caller(1)
      end
    end

    #
    # Remove the named field from the object.
    #
    def delete_field(name)
      @@table.delete name.to_sym
    end

    InspectKey = :__inspect_key__ # :nodoc:

    #
    # Returns a string containing a detailed summary of the keys and values.
    #
    def inspect
      str = "#<#{self.class}"

      Thread.current[InspectKey] ||= []
      if Thread.current[InspectKey].include?(self) then
        str << " ..."
      else
        first = true
        for k,v in @@table
          str << "," unless first
          first = false

          Thread.current[InspectKey] << v
          begin
            str << " #{k}=#{v.inspect}"
          ensure
            Thread.current[InspectKey].pop
          end
        end
      end

      str << ">"
    end
    alias :to_s :inspect

    attr_reader :table # :nodoc:
    protected :table

    #
    # Compare this object and +other+ for equality.
    #
    def ==(other)
      return false unless(other.kind_of?(OpenStruct))
      return @@table == other.table
    end

    def values_at(*keys)
      keys.map{|k| self[k]}
    end

    def []=(key, value)
      self.send("#{key}=", value)
    end

    def [](key)
      self.send(key)
    end
  end

  def inspect
      "<Global #{__id__}>"
  end
end
end
