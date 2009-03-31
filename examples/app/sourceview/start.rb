require 'rubygems'
require 'remarkably/engines/html'
require 'coderay'
require 'ramaze'

# where is the source
class MainController < Ramaze::Controller
  SOURCE_PATH = File.expand_path(File.join(Ramaze::ROOT, '../'))

  include Remarkably::Common

  helper :cache, :aspect
  engine :None

  def index *args
    redirect "/#/#{args.join('/')}" if args.size > 0
  end

  def source *args
    file = args.join('/')
    return if file.empty? or file =~ /\.{2}/

    file[0,0] = SOURCE_PATH + '/'
    CodeRay.scan_file(file).html(:line_numbers => :table) if File.file?(file)
  end

  before(:source){
    %(<link href='/coderay.css' rel='stylesheet' type='text/css' />) unless request.xhr?
  }

  def filetree
    ul(:class => 'filetree treeview'){
      Dir.chdir(SOURCE_PATH) do
        Dir['{benchmarks,doc,examples,lib,spec}'].map{|d| dir_listing(d) }
      end
    }.to_s
  end
  cache :filetree

  private

  def dir_listing(dir)
    li{
      span(dir, :class => 'folder')

      Dir.chdir(dir) do
        ul(:style => 'display: none;'){
          a('', :href => "##{File.expand_path('.').sub(SOURCE_PATH, '')}")

          Dir['*'].sort.each do |d|
            if File.directory?(d)
              dir_listing(d)
            else
              file = File.expand_path(d).sub(SOURCE_PATH, '')
              li{
                span(:class => 'file'){
                  a(d, :href => "##{file}")
                }
              }
            end
          end
        } if Dir['*'].any?
      end
    }
  end
end

# delete cached filetree when source changes
module Ramaze::SourceReloadHooks
  module_function
  def after_safe_load file
    Ramaze::Cache.actions.clear
  end
end

Ramaze.start :adapter      => :mongrel,
             :load_engines => :Haml,
             :boring       => /(js|gif|css)$/,
             :port         => 9950
