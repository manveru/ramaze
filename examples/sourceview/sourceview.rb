require 'rubygems'
require 'remarkably/engines/html'
require 'coderay'
require 'ramaze'

# where is the source
RAMAZE_SRC = File.expand_path(Ramaze::BASEDIR/'..') unless defined? RAMAZE_SRC

# delete cached filetree when source changes
module Ramaze::SourceReloadHooks
  module_function
  def after_safe_load file
    Ramaze::Cache.actions.delete '/filetree' if file =~ /^#{RAMAZE_SRC}/
  end
end

class MainController < Ramaze::Controller

  include Remarkably::Common
  helper :partial, :inform, :cache
  engine :None

  def source
    return if request['file'].nil? or request['file'] =~ /\.{2}/

    file = RAMAZE_SRC + request['file']
    if FileTest.file? file
      inform :info, "Showing source for #{file}"
      CodeRay.scan_file(file).html(:line_numbers => :table)
    end
  end

  def filetree
    ul :class => 'filetree treeview' do
      Dir.chdir(RAMAZE_SRC) do
        Dir['{benchmarks,doc,examples,lib,spec}'].collect do |d|
          dir_listing d
        end
      end
    end.to_s
  end
  cache :filetree

  private

  def dir_listing dir
    li do
      span dir, :class => 'folder'
      Dir.chdir(dir) do
        ul :style => 'display: none;' do
          a '', :href => "##{File.expand_path('.').sub(RAMAZE_SRC,'')}"
          Dir['*'].sort.each do |d|
            if FileTest.directory? d
              dir_listing d
            else
              file = File.expand_path(d).sub(RAMAZE_SRC,'')
              li do
                span :class => 'file' do
                  a d, :href => "##{file}"
                end
              end
            end
          end
        end if Dir['*'].any?
      end
    end
  end

end

Ramaze.start :adapter      => :mongrel,
             :load_engines => :Haml,
             :boring       => /(js|gif|css)$/,
             :port         => 9950