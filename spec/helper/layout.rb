require 'spec/helper/wrap'

class SpecLayout
  attr_accessor :base, :layout, :files

  def initialize(base, layout)
    @base, @layout = base, layout
  end

  def run
    build
    SpecWrap.new(@files).run
  end

  def build
    @files = gather(@base, @layout)
    @files = clean(@files, @layout)
  end

  def gather(base, layout)
    files = Set.new
    base = File.expand_path(base)

    layout.each do |key, value|
      if value.is_a?(Hash)
        files += gather(base/key, value)
      else
        glob = base/key/"#{value}.rb"
        files += Dir[glob].map{|f| File.expand_path(f)}
      end
    end

    files.reject{|f| File.directory?(f)}
  end

  def clean(files, layout)
    layout.each do |key, value|
      if value.is_a?(Hash)
        clean(files, value)
      else
        files.dup.each do |file|
          name = File.basename(file, File.extname(file))
          dir = file.gsub(File.extname(file), '')
          if name == key and File.directory?(dir)
            files.delete(file)
          end
        end
      end
    end

    files
  end
end
