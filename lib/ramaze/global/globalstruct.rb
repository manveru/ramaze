#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
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

    def setup(hash = {})
      hash.each do |key, value|
        self.send("#{key}=", value)
      end
      yield(self) if block_given?
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
      self[:sourcereload] = interval
      sri = Thread.main[:sourcereload]
      sri.interval = interval if sri
    end

    # External helpers

    def values_at(*keys)
      keys.map{|key| __send__(key)}
    end

    private # Internal helpers

    def create_member key, value = nil
      Inform.warn "Create #{key}=#{value.inspect} on Global"

      @table ||= {}
      key = key.to_sym

      (class << self; self; end).class_eval do
        define_method(key){ @table[key] }
        define_method("#{key}="){|val| @table[key] = val }
      end

      @table[key] = value
    end
  end
end
