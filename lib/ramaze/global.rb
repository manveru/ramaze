#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  class GlobalStruct < OpenStruct
    # autoreload    - Interval for autoreloading changed source in seconds
    # adapter       - Webserver-adapter ( :mongrel | :webrick )
    # cache         - Cache to use   ( MemcachedCache | MemoryCache | YamlStoreCache )
    # cache_actions - Finegrained caching based on actions (see CacheHelper)
    # cache_all     - Naive caching for all responses ( true | false )
    # error_page    - Show default errorpage with inspection and backtrace ( true | false )
    # host          - Host to respond to ( '0.0.0.0' )
    # mapping       - Route to controller map ( {} )
    # port          - First port of the port-range the adapters run on. ( 7000 )
    # run_loose     - Don't wait for the servers to finish, useful for testing ( true | false )
    # tidy          - Run all text/html responses through Tidy ( true | false )
    # template_root - Default directory for your templates.
    #
    # inform_to             - :stdout/'stdout'/$stderr (similar for stdout) or some path to a file
    # inform_tags           - a Set with any of [ :debug, :info, :error ]
    # inform_backtrace_size - size of backtrace to be logged (and show on error-page).
    # inform_timestamp      - parameter for Time.strftime
    # inform_prefix_info    - prefix for all the Inform#info messages
    # inform_prefix_debug   - prefix for all the Inform#debug messages
    # inform_prefix_error   - prefix for all the Inform#error messages

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
      :tidy           => false,
      :template_root  => 'template',

      :inform_to             => $stdout,
      :inform_tags           => Set.new([:debug, :info, :error]),
      :inform_backtrace_size => 10,
      :inform_timestamp      => "%Y-%m-%d %H:%M:%S",
      :inform_prefix_info    => 'INFO ',
      :inform_prefix_debug   => 'DEBUG',
      :inform_prefix_error   => 'ERROR',
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

    # iterate over the GlobalStruct, no guarantee on the order.

    def each
      table.each do |e|
        yield(e)
      end
    end
  end

  Thread.current[:global] = GlobalStruct.new(GlobalStruct::DEFAULT)
  Global = Thread.current[:global]
end
