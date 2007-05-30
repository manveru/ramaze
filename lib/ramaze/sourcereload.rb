#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'set'

module Ramaze
  class SourceReload
    attr_accessor :thread, :interval, :reload_glob, :map

    def initialize interval = 1, reload_glob = %r{(^\./)|#{Dir.pwd}|ramaze}
      @interval, @reload_glob = interval, reload_glob
      @mtimes, @map = {}, []
    end

    def start
      Inform.debug("initialize automatic source reload every #{interval} seconds")
      @thread = reloader
    end

    def self.startup options = {}
      interval = Global.sourcereload
      instance = new(interval)
      Thread.main[:sourcereload] = instance
      instance.reload # initial scan of all files
      instance.start if interval
    end

    def reloader
      Thread.new do
        loop do
          reload
          sleep(@interval)
        end
      end
    end

    # This method is quite handy if you want direct control over when your code is reloaded
    #
    # Usage example:
    #
    # trap :HUB do
    #   Ramaze::Inform.info "reloading source"
    #   Thread.main[:sourcereload].reload
    # end
    #

    def reload
      SourceReloadHooks.before_reload
      all_reload_files.each do |file|
        mtime = mtime(file)

        next if (@mtimes[file] ||= mtime) == mtime

        Inform.debug("reload #{file}")
        @mtimes[file] = mtime if safe_load(file)
      end
      SourceReloadHooks.after_reload
    end

    def all_reload_files
      files, paths = $LOADED_FEATURES, Array['', './', *$LOAD_PATH]

      unless [@files, @paths] == [files, paths]
        @files, @paths = files.dup, paths.dup

        map = files.map do |file|
          possible = paths.map{|pa| File.join(pa.to_s, file.to_s) }
          possible.find{|po| File.exists?(po) }
        end

        @map = map.compact
      end

      m = @map.grep(@reload_glob)
    end

    def mtime(file)
      File.mtime(file)
    rescue Errno::ENOENT
      false
    end

    def safe_load(file)
      SourceReloadHooks.before_safe_load(file)
      load(file)
      SourceReloadHooks.after_safe_load_succeed(file)
      true
    rescue Object => ex
      Inform.error(ex)
      SourceReloadHooks.after_safe_load_failed(file, ex)
      false
    end
  end

  # Holds hooks that are called before and after #reload and #safe_load

  module SourceReloadHooks
    module_function

    def before_reload
    end

    def after_reload
    end

    def before_safe_load(file)
    end

    def after_safe_load_succeed(file)
    end

    def after_safe_load_failed(file, error)
    end
  end
end
