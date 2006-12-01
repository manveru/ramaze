module Ramaze

  # this method loops through all loaded/required files
  # and re-loads them when they are updated.
  # It takes one parameter, which is the interval in seconds
  # with a default of 10.
  # You can also safely kill all threads (except for the main)
  # and it will just restart the autoreloader.

  def self.autoreload interval = 10
    gatherer = Thread.new do
      this = Thread.current
      this[:task] = :autoreload

      cache = {}

      loop do
        files = []
        $LOADED_FEATURES.map do |file|
          paths = $LOAD_PATH + ['']
          correct_path = paths.find{|lp| File.exist?(File.join(lp, file))}
          correct_file = File.expand_path(File.join(correct_path, file))

          files << correct_file
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
                Ramaze::Logger.info "autoreload #{file}"
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
