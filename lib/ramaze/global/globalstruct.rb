#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  unless defined?(GlobalStruct) # prevent problems for SourceReload
    class GlobalStruct < Struct.new('Global', *OPTIONS.keys)
    end
  end

  # Class for Ramaze::Global instance.
  class GlobalStruct

    # mapping of :adapter => to the right class-name.
    ADAPTER_ALIAS = {
      :webrick => :WEBrick,
      :mongrel => :Mongrel,
      :cgi     => :Cgi,
      :fcgi    => :Fcgi,
    }

    # mapping of :cache => to the right class-name.
    CACHE_ALIAS = {
      :memcached => :MemcachedCache,
      :memory    => :MemoryCache,
      :yaml      => :YAMLStoreCache,
    }

    class << self
      alias setup fill
    end

    # Called from Ramaze::start, sets all the options.
    def startup(options = {})
      options.each do |key, value|
        if (method(key) rescue false)
          send("#{key}=", value)
        else
          create_member(key, value)
        end
      end
    end

    # batch-assignment of key/value from hash, yields self if a block is given.
    def setup(hash = {})
      hash.each do |key, value|
        self.send("#{key}=", value)
      end
      yield(self) if block_given?
    end


    # Object wraps

    # get right classname, require the file for given adapter and answer with
    # the actual class.
    def adapter
      if internal = self[:adapter]
        class_name = ADAPTER_ALIAS[internal.to_sym]
        require("ramaze/adapter/"/class_name.to_s.downcase)
        adapter = Ramaze::Adapter.const_get(class_name)
      end
    end

    # get right classname, require the file for given cache and answer with
    # the actual class.
    def cache
      cache_name = self[:cache].to_sym
      class_name = CACHE_ALIAS[cache_name] || cache_name
      cache = Ramaze.const_get(class_name)
    end

    # a range built from port and the number of spawns.
    def ports
      (port.to_i..(port.to_i + (spawn.to_i - 1)))
    end

    # reassigns the interval in the instance of SourceReload that is running or
    # just waiting.
    def sourcereload=(interval)
      self[:sourcereload] = interval
      sri = Thread.main[:sourcereload]
      sri.interval = interval if sri
    end

    def template_root=(tr)
      self[:template_root] = File.expand_path(tr)
    end

    def public_root=(pr)
      self[:public_root] = File.expand_path(pr)
    end


    # External helpers

    # Answers with values for given keys by sending each to self
    def values_at(*keys)
      keys.map{|key| __send__(key)}
    end

    # Creates a new attr_accessor like method-pair.
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
