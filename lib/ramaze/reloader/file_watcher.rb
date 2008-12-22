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
  
  FileWatcher = StatFileWatcher
end
