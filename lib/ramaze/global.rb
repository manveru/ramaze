#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  class GlobalStruct < OpenStruct
    # autoreload     - Interval for autoreloading changed source in seconds
    # adapter        - Webserver-adapter ( :mongrel | :webrick )
    # cache          - Cache to use   ( MemcachedCache | MemoryCache | YamlStoreCache )
    # cache_actions  - Finegrained caching based on actions (see CacheHelper)
    # cache_all      - Naive caching for all responses ( true | false )
    # error_page     - Show default errorpage with inspection and backtrace ( true | false )
    # host           - Host to respond to ( '0.0.0.0' )
    # mapping        - Route to controller map ( {} )
    # port           - First port of the port-range the adapters run on. ( 7000 )
    # run_loose      - Don't wait for the servers to finish, useful for testing ( true | false )
    # tidy           - Run all text/html responses through Tidy ( true | false )
    # template_root  - Default directory for your templates.
    # backtrace_size - size of backtrace to be logged (and shown on error-page).
    #
    # startup         - List of methods and lambdas that are executed on startup
    # ramaze_startup  - Internal list of methods and lambdas that are executed on startup
    #
    # shutdown        - List of methods and lambdas that are executed on startup
    # ramaze_shutdown - Internal list of methods and lambdas that are executed on shutdown

    DEFAULT = {
      :autoreload     => 5,
      :adapter        => :webrick,
      :cache          => MemoryCache,
      :cache_actions  => Hash.new{|h,k| h[k] = Set.new},
      :cache_all      => false,
      :cookies        => true,
      :error_page     => true,
      :host           => '0.0.0.0',
      :mapping        => {},
      :port           => 7000,
      :run_loose      => false,
      :template_root  => 'template',
      :backtrace_size => 10,
      :logger         => Ramaze::Informer,
      :inform         => lambda{ Ramaze::Informer.trait   },
      :tidy           => lambda{ Ramaze::Tool::Tidy.trait },

      :startup => [],
      :ramaze_startup => [
        lambda{
          Ramaze.const_set(:Inform, Global.logger.startup )
          Inform.info("Starting up Ramaze (Version #{VERSION})")
        },
        :setup_controllers, :init_autoreload, :init_adapter
      ],

      :shutdown => [],
      :ramaze_shutdown => [
        :kill_threads,
        :close_inform,
        lambda{
          Informer.shutdown
          puts("Shutdown Ramaze (it's save to kill me now if i hang)")
        },
        :exit
      ],
    }

    # takes an hash of options and optionally an block that is evaled in this
    # instance of GlobalStruct.

    def setup hash = {}, &block
      Global.instance_eval(&block) if block_given?
      table.merge!( hash.keys_to_sym )
    end

    # just update the hash, not deleting values already set.
    # again, takes a block, but your assignments may be
    # overwritten if they existed before.

    def update hash = {}, &block
      old_table = table.dup
      Global.instance_eval(&block) if block_given?
      table.merge!( hash.keys_to_sym.merge( old_table ) )
    end

    # synonym to Global.key = value

    def []=(key, value)
      table[key.to_sym] = value
    end

    # synonym for Global.key

    def [](key)
      table[key.to_sym]
    end

    # get all the values for the given keys in the right order.

    def values_at(*keys)
      table.values_at(*keys.map(&:to_sym))
    end

    # all keys already set

    def keys
      table.keys
    end

    # iterate over the GlobalStruct, no guarantee on the order.

    def each
      table.each do |e|
        yield(e)
      end
    end

    def inspect
      table.inspect
    end

    def pretty_inspect
      table.pretty_inspect
    end

    def new_ostruct_member(name)
      name = name.to_sym
      unless self.respond_to?(name)
        meta = class << self; self; end
        meta.send(:define_method, name) {
          sel = @table[name]
          if sel.respond_to?(:call)
            sel.call
          else
            sel
          end
        }
        meta.send(:define_method, :"#{name}=") {|x|
          sel = @table[name]
          if sel.respond_to?(:call)
            sel.call("#{name}=", x)
          else
            @table[name] = x
          end
        }
      end
    end
  end

  Thread.current[:global] = GlobalStruct.new(GlobalStruct::DEFAULT)
  Global = Thread.current[:global]
end
