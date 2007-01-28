#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  class GlobalStruct < OpenStruct
    # The default variables for Global:
    #   uses the class from Adapter:: (is required automatically)
    #       Global.adapter #=> :webrick
    #   restrict access to a specific host
    #       Global.host #=> '0.0.0.0'
    #   adapter runs on that port
    #       Global.port #=> 7000
    #   the running/debugging-mode (:debug|:stage|:live|:silent) - atm only differ in verbosity
    #       Global.mode #=> :debug
    #   detaches Ramaze to run in the background (used for testcases)
    #       Global.run_loose #=> false
    #   caches requests to the controller based on request-values (action/params)
    #       Global.cache #=> false
    #   run tidy over the generated html if Content-Type is text/html
    #       Global.tidy #=> false
    #   display an error-page with backtrace on errors (empty page otherwise)
    #       Global.error_page    #=> true
    #   trap this signal for clean shutdown (calls Ramaze.shutdown)
    #       Global.shutdown_trap #=> 'SIGINT'

    DEFAULT = {
      # Interval for autoreload
      :autoreload     => 5,
      # The adapter to run with ( webrick | mongrel )
      :adapter        => :webrick,
      # The caching to use ( MemoryCache | MemcachedCache | YAMLStoreCache )
      :cache          => MemoryCache,
      # Cache all responses based on a simple mapping of the call-parameters
      :cache_all      => false,
      # Show the default Errorpage of Ramaze
      :error_page     => true,
      # What hosts to respond to.
      :host           => '0.0.0.0',
      # What port to run on
      :port           => 7000,
      # The mapping of the Controllers, format {'/' => Foo, '/bar' => Bar}
      :mapping        => {},
      # Pass on control after startup.
      :run_loose      => false,
      # Run tidy over every response of type 'text/html'.
      :tidy           => false,
      # The place your templates are located, relative to the place you start.
      :template_root  => 'template',
      # Used by CacheHelper.
      :cache_actions  => Hash.new{|h,k| h[k] = Set.new},

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
      table.merge!(hash)
    end

    # just update the hash, not deleting values already set.
    # again, takes a block, but your assignments may be
    # overwritten if they existed before.

    def update hash = {}, &block
      old_table = table.dup
      Global.instance_eval(&block) if block_given?
      table.merge!(hash.merge(old_table))
    end

    # synonym to Global.key = value

    def []=(key, value)
      table[key] = value
    end

    # synonym for Global.key

    def [](key)
      table[key]
    end

    # get all the values for the given keys in the right order.

    def values_at(*keys)
      table.values_at(*keys)
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
