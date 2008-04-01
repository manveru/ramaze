module Ramaze

  # A alike of attr_accessor and friends, but for thread variables in
  # Thread::current
  module ThreadAccessor

    # Iterate over the names and yield accordingly.
    # names are either objects responding to #to_sym or hashes.
    #
    # It's only used within this module for abstractin-purposes.
    # Usage below.
    def self.each(*names)
      names.each do |name|
        if name.respond_to?(:to_hash)
          name.to_hash.each do |key, meth|
            key, meth = key.to_sym, meth.to_sym
            yield key, meth
          end
        else
          key = meth = name.to_sym
          yield key, meth
        end
      end
    end

    # thread_writer and thread_reader, initializer is a block that may be given
    # and its result will be the new value in case the reader was never called
    # before or the value wasn't set before.
    def thread_accessor(*names, &initializer)
      thread_writer(*names)
      thread_reader(*names, &initializer)
    end

    # Simple writer accessor to Thread::current[key]=
    def thread_writer(*names)
      ThreadAccessor.each(*names) do |key, meth|
        define_method("#{meth}="){|obj| Thread.current[key] = obj }
      end
    end

    # Reader accessor for Thread::current[key]
    def thread_reader(*names, &initializer)
      ThreadAccessor.each(*names) do |key, meth|
        if initializer
          define_method(meth) do
            unless Thread.current.key?(key)
              Thread.current[key] = instance_eval(&initializer)
            else
              Thread.current[key]
            end
          end
        else
          define_method(meth){ Thread.current[key] }
        end
      end
    end
  end
end
