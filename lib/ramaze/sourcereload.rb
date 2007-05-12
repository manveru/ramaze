#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'set'

module Ramaze
  class SourceReload
    attr_accessor :thread, :interval, :reload_glob, :map

    def initialize interval = 1, reload_glob = /#{Dir.pwd}|ramaze/
      @interval, @reload_glob = interval, reload_glob
      @mtimes, @map = {}, []
    end

    def start
      Inform.debug("initialize automatic source reload every #{interval} seconds")
      @thread = reloader
    end

    def self.start(*args)
      instance = new(*args)
      instance.start
      instance
    end
    
    def reloader
      Thread.new do
        loop do
          all_reload_files.each do |file|
            mtime = mtime(file)

            next if (@mtimes[file] ||= mtime) == mtime

            sleep(@interval / files.size.to_f)
            Inform.debug("reload #{file}")
            @mtimes[file] = mtime if safe_load(file)
          end
        end
      end
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
      load(file)
      true
    rescue Object => ex
      Inform.error(ex)
      false
    end
  end
end
