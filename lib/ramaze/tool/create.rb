#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'fileutils'
require 'yaml'

module Ramaze
  module Tool
    class Create
      class << self
        def create project
          @basedir = ::Ramaze::BASEDIR / 'proto'
          @destdir = Dir.pwd / project

          puts "creating project: #{project}"

          FileUtils.mkdir_p(project)

          puts "copy proto to new project (#@destdir)..."

          directories, files =
            Dir[@basedir / '**' / '*'].partition{|f| File.directory?(f) }

          create_dirs(*directories)
          copy_files(*files)

        end

        def create_dirs(*dirs)
          dirs.each do |dir|
            dest = dir.gsub(@basedir, @destdir)

            puts "create directory: '#{dest}'"
            FileUtils.mkdir_p(dest)
          end
        end

        def copy_files(*files)
          files.each do |file|
            dest = file.gsub(@basedir, @destdir)

            puts "copy file: '#{dest}'"
            FileUtils.cp(file, dest)
          end
        end
      end
    end
  end
end
