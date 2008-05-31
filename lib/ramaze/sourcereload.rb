#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # SourceReload provides a way to reload changed files automatically during
  # runtime. Its default behaviour in Ramaze is to check periodically for
  # files with newer mtime and then attempts to load them in a controlled
  # manner.

  class SourceReload

    # Called from Ramaze::startup, just assigns a new instance to
    # Global.sourcreloader
    def self.startup(options = {})
      Global.sourcereloader = new
    end

    # Setup the @mtimes hash. any new file will be assigned it's last modified
    # time (mtime) so we don't reload a file when we see it the first time.
    #
    # The thread only runs if Global.sourcereload is set.
    def initialize
      @mtimes = Hash.new{|h,k| h[k] = mtime(k) }

      Thread.new do
        Thread.current.priority = -1

        while interval = Global.sourcereload
          rotate
          sleep interval
        end
      end
    end

    # One iteration of rotate will look for files that changed since the last
    # iteration and will try to #safe_load it.
    # This method is quite handy if you want direct control over when your
    # code is reloaded.
    #
    # Usage example:
    #
    #   trap :HUP do
    #     Ramaze::Log.info "reloading source"
    #     Ramaze::Global.sourcereloader.rotate
    #   end
    #

    def rotate
      before_rotation

      rotation do |file|
        mtime = mtime(file)

        if mtime > @mtimes[file]
          Log.debug("reload #{file}")
          safe_load(file)
          @mtimes[file] = mtime(file)
        end
      end

      after_rotation
    end

    # Iterates over the $LOADED_FEATURES ($") and $LOAD_PATH ($:) and tries to
    # find either absolute paths or tries to find one by combining paths and files.
    # Every found file is yielded to the rotate method.

    def rotation
      files = Array[$0, *$LOADED_FEATURES]
      paths = Array['./', *$LOAD_PATH]

      files.each do |file|
        if Pathname.new(file).absolute?
          yield(file) if File.file?(file)
        else
          paths.each do |path|
            full = File.join(path, file)
            break yield(full) if File.file?(full)
          end
        end
      end
    end

    # Safe mtime
    def mtime(file)
      File.mtime(file)
    rescue Errno::ENOENT
      false
    end

    # A safe Kernel::load, issuing the hooks depending on the results
    def safe_load(file)
      before_safe_load(file)
      load(file)
      after_safe_load_succeed(file)
    rescue Object => ex
      after_safe_load_failed(file, ex)
    end
  end

  # Holds hooks that are called before and after #reload and #safe_load

  module SourceReloadHooks
    # Overwrite to add actions before the reload rotation is started.

    def before_rotation
    end

    # Overwrite to add actions after the reload rotation has ended.

    def after_rotation
    end

    # Overwrite to add actions before a file is Kernel::load-ed

    def before_safe_load(file)
    end

    # Overwrite to add actions after a file is Kernel::load-ed successfully,
    # by default we clean the Cache for compiled templates and resolved actions.

    def after_safe_load_succeed(file)
      Cache.compiled.clear
      Cache.resolved.clear
      Cache.action_methods.clear
      after_safe_load(file)
    end

    # Overwrite to add custom hook in addition to default Cache cleaning

    def after_safe_load(file)
    end

    # Overwrite to add actions after a file is Kernel::load-ed unsuccessfully,
    # by default we output an error-message with the exception.

    def after_safe_load_failed(file, error)
      Log.error(error)
    end
  end

  class SourceReload
    include SourceReloadHooks
  end
end
