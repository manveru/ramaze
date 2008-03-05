module Ramaze
  module ThreadAccessor
    def ThreadAccessor.each(*names)
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

    def thread_accessor(*names, &initializer)
      thread_writer(*names)
      thread_reader(*names, &initializer)
    end

    def thread_writer(*names)
      ThreadAccessor.each(*names) do |key, meth|
        define_method("#{meth}="){|obj| Thread.current[key] = obj }
      end
    end

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
