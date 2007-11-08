#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/spec/helper/wrap'

class SpecLayout
  attr_accessor :base, :layout, :files

  def initialize(base, layout)
    @base, @layout = base, layout
  end

  def run
    SpecWrap.new(@files).run
  end

  def gather
    @files = gather_files(@base, @layout)
  end

  def gather_files(base, layout)
    files = Set.new
    base = File.expand_path(base)

    layout.each do |key, value|
      if value.is_a?(Hash)
        files += gather_files(base/key, value)
      else
        glob = base/key/"#{value}.rb"
        files += Dir[glob].map{|f| File.expand_path(f)}
      end
    end

    files.reject{|f| File.directory?(f)}
  end

  def clean
    @files = clean_files(@files, @layout)
  end

  def clean_files(files, layout)
    layout.each do |key, value|
      if value.is_a?(Hash)
        clean_files(files, value)
      elsif files
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
