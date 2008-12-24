module Ramaze
  class Reloader
    class WatchInotify
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
  end
end
