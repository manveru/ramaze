module Ramaze

  class StatFileWatcher
    def initialize
      # @files[file_path] = stat
      @files = {}
    end

    # start watching a file for changes
    # true if succeeded, false if failure
    def watch(file)
      # if already watching
      return true if @files.has_key?(file)
      begin
        @files[file] = File.stat(file)
      rescue Errno::ENOENT, Errno::ENOTDIR
        # doesn't exist => failure
        return false
      end
      # success
      true
    end

    # stop watching a file for changes
    def remove_watch(file)
      @files.delete(file)
      true
    end

    # return files changed since last call
    def changed_files
      changed = []
      @files.each do |file, stat|
        new_stat = File.stat(file)
        if new_stat.mtime > stat.mtime
          changed << file
          @files[file] = new_stat
        end
      end
      changed
    end
  end
  
  class InotifyFileWatcher
    POLL_TIMEOUT = 2
    def initialize
      @watcher = RInotify.new
      @changed = []
      @mutex = Mutex.new
      @watcher_thread = Thread.new do
        while true
          # FIXME:
          #   if files are added while waiting,
          #   only events that happen after next call are seen
          if @watcher.wait_for_events(POLL_TIMEOUT)
            changed_descriptors = []
            @watcher.each_event do |ev|
              changed_descriptors << ev.watch_descriptor
            end
            @mutex.synchronize do
              @changed += changed_descriptors.map {|des| @watcher.watch_descriptors[des] }
            end
          end
        end
      end
    end

    def watch(file)
      if not @watcher.watch_descriptors.values.include?(file) and File.exist?(file)
        @mutex.synchronize { @watcher.add_watch(file, RInotify::MODIFY) }
        return true
      end
      false
    end

    def remove_watch(file)
      @mutex.synchronize { @watcher.rm_watch(file) }
      true
    end

    def changed_files
      @mutex.synchronize do
        @tmp = @changed
        @changed = []
      end
      @tmp.uniq!
      @tmp
    end
  end

  begin
    gem 'RInotify', '>=0.9' # is older version ok?
    require 'rinotify'
    FileWatcher = InotifyFileWatcher
  rescue Gem::LoadError, LoadError
    # stat always available
    FileWatcher = StatFileWatcher
  end
end
