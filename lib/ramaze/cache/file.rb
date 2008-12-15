module Ramaze
  # Persist cache contents to the filesystem.
  # Will create a `/cache` directory in your APPDIR
  #
  # Usage for sessions only:
  #
  #     Ramaze::Global::cache_alternative[:sessions] = Ramaze::FileCache
  #
  # Usage for everything:
  #
  #     Ramaze::Global::cache = Ramaze::FileCache

  class FileCache
    HOST = Socket.gethostname
    ROOT = File.join(Ramaze::APPDIR, 'cache')
    PID  = Process.pid

    FileUtils.mkdir_p(ROOT)

    def self.[](key)
      path = File.join(ROOT, key.to_s, "data")
      Marshal.load(File.read(path))
    rescue
      nil
    end

    def self.[]=(key, value)
      key     = key.to_s
      tmp     = File.join(ROOT, key, "data.#{HOST}.#{PID}")
      path    = File.join(ROOT, key, "data")
      dirname = File.join(ROOT, key)

      data = Marshal.dump(value)

      FileUtils.rm_rf(dirname)
      FileUtils.mkdir_p(dirname)
      File.open(tmp, 'w'){|fd| fd.write(data) }
      FileUtils.mv(tmp, path)

      return value
    end

    def self.values_at(*keys)
      keys.map{|key| self[key] }
    end

    def self.delete(*keys)
      keys.map do |key|
        dirname = File.join(ROOT, key)
        FileUtils.rm_rf(dirname)
      end
    end

    def self.clear
      Dir["#{ROOT}/*"].each{|entry| FileUtils.rm_rf(entry) }
    end

    def self.new
      self
    end

    def self.to_sym
      name.split('::').last.to_sym
    end
  end
end
