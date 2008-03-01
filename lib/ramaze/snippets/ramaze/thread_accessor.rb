module Ramaze
  # TODO:
  #   * refactor _writer/_reader to use a common method, but how to solve block
  #     scope issues?
  module ThreadAccessor
    def thread_accessor(*names)
      thread_writer(*names)
      thread_reader(*names)
    end

    def thread_writer(*names)
      names.each do |name|
        if name.respond_to?(:to_hash)
          name.to_hash.each do |key, meth|
            key = key.to_sym
            define_method("#{meth}="){|obj| Thread.current[key] = obj }
          end
        else
          name = name.to_sym
          define_method("#{name}="){|obj| Thread.current[name] = obj }
        end
      end
    end

    def thread_reader(*names)
      names.each do |name|
        if name.respond_to?(:to_hash)
          name.to_hash.each do |key, meth|
            key = key.to_sym
            define_method(meth){ Thread.current[key] }
          end
        else
          name = name.to_sym
          define_method(name){ Thread.current[name] }
        end
      end
    end
  end
end
