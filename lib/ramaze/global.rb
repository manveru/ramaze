#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  CLIOption = Struct.new('CLIOption', :name, :default, :doc, :cli)
  OPTIONS     = {}
  CLI_OPTIONS = []

  def self.o(doc, options = {})
    cli_given = options.has_key?(:cli)
    cli = options.delete(:cli)
    name, default = options.to_a.flatten
    CLI_OPTIONS << CLIOption.new(name, default, doc, cli) if cli_given
    OPTIONS.merge!(options)
  end

  o "Set the adapter Ramaze will run on.",
    :adapter => :webrick, :cli => [:webrick, :mongrel]

  o "All running threads of Adapter will be collected here.",
    :adapters => Set.new

  o "Set the size of Backtrace shown.",
    :backtrace_size => 10, :cli => 10

  o "Turn benchmarking every request on.",
    :benchmarking => false, :cli => false

  o "Use this for general caching and as base for Cache.new.",
    :cache => :memory, :cli => [:memory, :memcached, :yaml]

  o "Turn on naive caching of all requests.",
    :cache_all => false, :cli => false

  o "Turn on cookies for all requests.",
    :cookies => true, :cli => true

  o "All subclasses of Controller are collected here.",
    :controllers => Set.new

  o "Start Ramaze within an IRB session",
    :console => false, :cli => false

  o "Turn on customized error pages.",
    :error_page => true, :cli => true

  o "Specify what IP Ramaze will respond to - 0.0.0.0 for all",
    :host => "0.0.0.0", :cli => '0.0.0.0'

  o "All paths to controllers are mapped here.",
    :mapping => {}

  o "Specify port",
    :port => 7000, :cli => 7000

  o "Specify the shadowing public directory (default in proto)",
    :public_root => ( BASEDIR / 'proto' / 'public' )

  o "Record all Request objects by assigning a filtering Proc to me.",
    :record => false

  o "Don't wait until all adapter-threads are finished or killed.",
    :run_loose => false, :cli => false

  o "Turn on BF/DoS protection for error-responses",
    :shield => false, :cli => false

  o "What signal to trap to call Ramaze::shutdown",
    :shutdown_trap => "SIGINT"

  o "Interval in seconds of the background SourceReload",
    :sourcereload => 3, :cli => 3

  o "How many adapters Ramaze should spawn.",
    :spawn => 1, :cli => 1

  o "Test before start if adapters will be able to connect",
    :test_connections => true, :cli => true

  o "Specify template root for dynamic files relative to main.rb",
    :template_root => 'template'

  class GlobalStruct < Struct.new('Global', *OPTIONS.keys)
    ADAPTER_ALIAS = {
      :webrick => :WEBrick,
      :mongrel => :Mongrel,
      :cgi     => :CGI,
      :fcgi    => :Fcgi,
    }

    CACHE_ALIAS = {
      :memcached => :MemcachedCache,
      :memory    => :MemoryCache,
      :yaml      => :YAMLStoreCache,
    }

    class << self
      def setup options = {}
        self.fill(options)
      end
    end

    # Object wraps

    def adapter
      if internal = self[:adapter]
        class_name = ADAPTER_ALIAS[internal.to_sym]
        require "ramaze/adapter/#{class_name.to_s.downcase}"
        adapter = Ramaze::Adapter.const_get(class_name)
      end
    end

    def cache
      cache_name = self[:cache].to_sym
      class_name = CACHE_ALIAS[cache_name] || cache_name
      cache = Ramaze.const_get(class_name)
    end

    def ports
      (port..(port + (spawn - 1)))
    end

    def sourcereload=(interval)
      sri = Thread.main[:sourcereload]
      sri.interval = interval
      self[:sourcereload] = interval
    end

    # External helpers

    def values_at(*keys)
      keys.map{|key| __send__(key)}
    end

    private # Internal helpers

    def create_member key, value = nil
      @table ||= {}
      key = key.to_sym

      (class << self; self; end).class_eval do
        define_method(key){ @table[key] }
        define_method("#{key}="){|val| @table[key] = val }
      end

      @table[key] = value
    end
  end

  Global = GlobalStruct.setup(OPTIONS)

  def Global.startup(options = {})
    options.each do |key, value|
      if (method(key) rescue false)
        self[key] = value
      else
        create_member(key, value)
      end
    end
  end
end
