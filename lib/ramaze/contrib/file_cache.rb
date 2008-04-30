#
# drop-in replacement for Ramaze's built-in MemoryCache built on the
# filesystem.  # to use with sessions do
#
#   Ramaze::Global::cache_alternative[:sessions] = Ramaze::FileCache
#
# to use with everything do
#
#   Ramaze::Global::cache = Ramaze::FileCache
#

module Ramaze::FileCache
  require "fileutils"
  require "socket"

  Host = Socket.gethostname
  Pid = Process.pid
  Fu = FileUtils
  Root = File.join Ramaze::APPDIR, "cache"

  Fu.mkdir_p(Root) rescue nil

  def self.[] key
    path = File.join Root, key, "data"
    Marshal.load(IO.read(path))
  rescue
    nil
  end

  def self.[]= key, value
    tmp = File.join Root, key, "data.#{ Host }.#{ Pid }"
    dirname = File.join Root, key
    path = File.join Root, key, "data"
    data = Marshal.dump value
    Fu.rm_rf dirname rescue nil
    Fu.mkdir_p dirname rescue nil
    open(tmp, 'w'){|fd| fd.write data}
    Fu.mv tmp, path
  rescue
    nil
  end

  def self.values_at *keys
    keys.map{|key| self[key]}
  end

  def self.delete *keys
    keys.map do |key|
      dirname = File.join Root, key
      Fu.rm_rf dirname rescue next
    end
  end

  def self.clear
    Dir["#{ Root }/*"].each{|entry| Fu.rm_rf entry}
  end

  def self.new
    self
  end

  def self.to_sym
    name.split(%r/::/).last.to_sym
  end
end
