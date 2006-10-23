module Ramaze

  # this method loops through all loaded/required files
  # and re-loads them when they are updated.
  # It takes one parameter, which is the interval in seconds
  # with a default of 10.
  # You can also safely kill all threads (except for the main)
  # and it will just restart the autoreloader.

  def autoreload interval = 10
    gatherer = Thread.new do
      this = Thread.current
      cache = {}
      this[:interval] = interval
      joiner = lambda{|path, file| File.expand_path(File.join(path, file))}
      loop do
        (this[:files] ||= []).dup.each do |file|
          this[:files].delete(file) unless File.exist?(file)
        end
        $".each do |file|
          paths = $LOAD_PATH + ['']
          correct_path = paths.find{|lp| File.exist?(joiner[lp, file])}
          correct_file = joiner[correct_path, file]
          this[:files] << correct_file unless this[:files].include?(correct_file)
        end
        sleep(this[:interval] ||= interval)
      end
    end

    reloader = Thread.new do
      this = Thread.current
      cache = {}
      this[:interval] = interval
      sleep 0.1 until gatherer[:files] # wait for the gatherer
      loop do
        begin
          gatherer[:files].each do |file|
            current_time = File.mtime(file)
            if last_time = cache[file]
              unless last_time == current_time
                begin
                  print "reloading #{file} ... "
                  load(file)
                  puts "successfully."
                  cache[file] = current_time
                rescue Object => ex # catches errors when the load fails
                  # in case mtime fails
                  puts "failed."
                end
              end
            else
              cache[file] = current_time
            end
            # sleep a total of reloader[:interval], 
            # but spread it evenly on all files
            sleep(this[:interval].to_f / gatherer[:files].size)
          end
        rescue Object => ex
          unless ex.message =~ /no such file or directory/
            puts ex
            puts ex.backtrace
          end
        end
      end
    end
  end
end
