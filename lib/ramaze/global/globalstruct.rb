#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  unless defined?(GlobalStruct) # prevent problems for SourceReload
    class GlobalStruct < Struct.new('Global', *OPTIONS.keys)
    end
  end

  # Class for Ramaze::Global instance.
  class GlobalStruct

    ENV_TRIGGER = {
      'EVENT' => lambda{ require 'ramaze/adapter/evented_mongrel' },
      'SWIFT' => lambda{ require 'ramaze/adapter/swiftiplied_mongrel' }
    }

    # mapping of :adapter => to the right class-name.
    ADAPTER_ALIAS = {
      :cgi                 => :Cgi,
      :fcgi                => :Fcgi,
      :scgi                => :Scgi,
      :thin                => :Thin,
      :ebb                 => :Ebb,
      :lsws                => :Lsws,
      :webrick             => :WEBrick,
      :mongrel             => :Mongrel,
      :evented_mongrel     => :Mongrel,
      :swiftiplied_mongrel => :Mongrel,
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

      ENV_TRIGGER.values_at(*ENV.keys).compact.each{|l| l.call}

      engines = self[:load_engines]
      (Symbol === engines ? [engines] : engines).each do |engine|
        Ramaze::Template.const_get(engine)
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
        class_name = ADAPTER_ALIAS.fetch(internal.to_sym, internal)
        unless Ramaze::Adapter.const_defined?(class_name)
          require("ramaze/adapter"/internal.to_s.downcase)
        end
        Ramaze::Adapter.const_get(class_name)
      end
    end

    # get right classname, require the file for given cache and answer with
    # the actual class.
    def cache
      cache_name = self[:cache].to_sym
      class_name = CACHE_ALIAS[cache_name] || cache_name
      cache = Ramaze.const_get(class_name)
    end

    # reassigns the interval in the instance of SourceReload that is running or
    # just waiting.
    def sourcereload=(interval)
      self[:sourcereload] = interval
      sri = Thread.main[:sourcereload]
      sri.interval = interval if sri
    end

    # Find a suitable template_root, if none of these is a directory just use
    # the currently set one.
    def template_root
      [ tr = self[:template_root],
        APPDIR/tr,
        APPDIR/'template',
      ].find{|path| File.directory?(path) } || self[:template_root]
    end

    # Find a suitable public_root, if none of these is a directory just use the
    # currently set one.
    def public_root
      [ pr = self[:public_root],
        APPDIR/pr,
      ].find{|path| File.directory?(path) } || self[:public_root]
    end

    # Inject the Ramaze::Dispatcher::Directory if this is set to true
    def list_directories=(active)
      require 'ramaze/dispatcher'
      d = Ramaze::Dispatcher
      self[:list_directories] = active
      if active
        d::FILTER.put_within(d::Directory, :after => d::File, :before => d::Action)
      else
        d::FILTER.delete(d::Directory)
      end
    end


    # External helpers

    # Answers with values for given keys by sending each to self
    def values_at(*keys)
      keys.map{|key| __send__(key)}
    end

    # Creates a new attr_accessor like method-pair.
    def create_member key, value = nil
      Log.warn "Create #{key}=#{value.inspect} on Global"

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
