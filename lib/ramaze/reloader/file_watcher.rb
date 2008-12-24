module Ramaze
  class Reloader
    class StatFileWatcher
      def initialize
        # @files[file_path] = stat
        @files = {}
        @last = Time.now
      end

      def call(cooldown)
        if cooldown and Time.now > @last + cooldown
          yield
          @last = Time.now
        end
      end

      # start watching a file for changes
      # true if succeeded, false if failure
      def watch(file)
        return true if watching?(file) # if already watching
        if stat = safe_stat(file)
          @files[file] = stat
        end
      end

      def watching?(file)
        @files.has_key?(file)
      end

      # stop watching a file for changes
      def remove_watch(file)
        @files.delete(file)
      end

      # no need for cleanup
      def close
      end

      # return files changed since last call
      def changed_files
        changed = []

        @files.each do |file, stat|
          if new_stat = safe_stat(file)
            if new_stat.mtime > stat.mtime
              changed << file
              @files[file] = new_stat
            end
          end
        end

        changed
      end

      def safe_stat(file)
        File.stat(file)
      rescue Errno::ENOENT, Errno::ENOTDIR
        nil
      end
    end

    class InotifyFileWatcher
      POLL_INTERVAL = 2 # seconds

      def initialize
        @watcher = RInotify.new
        @changed = []
        @mutex = Mutex.new
        @watcher_thread = start_watcher
      end

      def call(cooldown)
        yield if @changed.any?
      end

      # TODO: define a finalizer to cleanup? -- reloader never calls #close

      def start_watcher
        Thread.new do
          loop do
            watcher_cycle
            sleep POLL_INTERVAL
          end
        end
      end

      def watcher_cycle
        return unless @watcher.wait_for_events(0)
        changed_descriptors = []

        @watcher.each_event do |event|
          changed_descriptors << event.watch_descriptor
        end

        @mutex.synchronize do
          changed_descriptors.each do |descriptor|
            @changed << @watcher.watch_descriptors[descriptor]
          end
        end
      end

      def watch(file)
        return false if @watcher.watch_descriptors.has_value?(file)
        return false unless File.exist?(file)

        @mutex.synchronize{ @watcher.add_watch(file, RInotify::MODIFY) }

        true
      end

      def remove_watch(file)
        @mutex.synchronize{ @watcher.rm_watch(file) }
        true
      end

      def close
        @watcher_thread.terminate
        @watcher.close
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
    rescue LoadError
      # stat always available
      FileWatcher = StatFileWatcher
    end
  end
end
