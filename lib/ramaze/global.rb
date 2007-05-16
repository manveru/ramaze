#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  OPTIONS = {
    :adapter          => :webrick,
    :adapters         => Set.new,
    :backtrace_size   => 10,
    :benchmarking     => false,
    :cache            => :memory,
    :cache_all        => false,
    :cookies          => true,
    :controllers      => Set.new,
    :error_page       => true,
    :host             => '0.0.0.0',
    :mapping          => {},
    :port             => 7000,
    :public_root      => ( BASEDIR / 'proto' / 'public' ),
    :run_loose        => false,
    :shield           => false,
    :shutdown_trap    => 'SIGINT',
    :sourcereload     => 3,
    :test_connections => true,
    :template_root    => 'template',
  }

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
      return @ports if defined?(@ports)
      from_port, to_port = self[:port].to_s.split('..')

      ports =
        if from_port and to_port
          (from_port.to_i..to_port.to_i)
        else
          (from_port.to_i..from_port.to_i)
        end

      self[:port] = ports.begin
      @ports = ports
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
