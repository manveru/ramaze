#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'set'

module Ramaze

  RELOAD_ENV = {
    :glob => /#{Dir.pwd}|ramaze/
  }

  class << self
    def reload interval = 1
      Inform.debug("initialize automatic file reload every #{interval} seconds")

      Thread.new do
        this = Thread.current
        this[:task] = :autoreload

        mtimes = {}

        loop do
          to_reload = all_reload_files.reject do |file|
            mtime = File.mtime(file)
            mtimes[file] ||= mtime
            mtimes[file] == mtime
          end

          to_reload.each do |file|
            sleep(interval / files.size.to_f)
            Inform.debug("reload #{file}")
            mtimes[file] = mtime if safe_load(file)
          end
        end
      end
    end

    def all_reload_files
      env = RELOAD_ENV

      files, paths = $LOADED_FEATURES, $LOAD_PATH

      unless env[:files] == files and env[:paths] == paths
        env[:files], env[:paths] = files.dup, paths.dup
        env[:map] = files.map do |file|
          possible = paths.map{|pa| File.join(pa.to_s, file.to_s) }
          possible.find{|po| File.exists?(po) }
        end
        env[:map] = env[:map].compact.sort
      end

      env[:map].select{|f| f =~ env[:glob] }
    end

    def safe_load(file)
      load(file)
      true
    rescue Object => ex
      Inform.error(ex)
      false
    end
  end

  # this method loops through all loaded/required files
  # and re-loads them when they are updated.
  # It takes one parameter, which is the interval in seconds
  # with a default of 10.
  # You can also safely kill all threads (except for the main)
  # and it will just restart the autoreloader.

  def self.autoreload interval = 10
    Inform.debug("initialize autoreload with an interval of #{interval} seconds")

    gatherer = Thread.new do
      this = Thread.current
      this[:task] = :autoreload

      cache = {}
      file_set = Set.new

      loop do
        files = file_set.dup
        $LOADED_FEATURES.map do |file|
          file = file.to_s
          paths = $LOAD_PATH + ['']
          correct_path = paths.find{|lp| File.exist?(File.join(lp.to_s, file))}
          correct_file = File.expand_path(File.join(correct_path, file)) if correct_path

          files << correct_file if correct_file
        end

        this[:files] = files

        sleep_interval = this[:interval] ||= interval || 10
        sleep sleep_interval
      end
    end

    reloader = Thread.new do
      this = Thread.current
      this[:task] = :autoreload

      cache = {}
      this[:interval] = interval
      sleep 0.1 until gatherer[:files] # wait for the gatherer

      loop do
        gatherer[:files].each do |file|
          begin
            current_time = File.mtime(file)
            if last_time = cache[file]
              unless last_time == current_time
                Inform.info("autoreload #{file}")
                load(file)
                cache[file] = current_time
              end
            else
              cache[file] = current_time
            end
          rescue Object => ex # catches errors when the load fails
            # in case mtime fails
            unless ex.message =~ /No such file or directory/
              puts ex
              puts ex.backtrace
            end
            # sleep a total of reloader[:interval],
            # but spread it evenly on all files
          end # begin
          sleep_interval = this[:interval].to_f / gatherer[:files].size
          sleep sleep_interval
        end # each
      end # loop
    end # Thread.new
  end # autoreload
end # Ramaze
