require 'rubygems'
require 'remarkably/engines/html'
require 'coderay'
require 'ramaze'

# make sure to look for .haml templates
Ramaze::Template::Haml

# where is the source
RAMAZE_SRC = '/Users/aman/ramaze'

class Ramaze::Template::NoTemplate < Ramaze::Template::Template
  def self.transform action
    render_method(action)
  end
end

class MainController < Ramaze::Controller

  trait :engine => Ramaze::Template::NoTemplate
  include Remarkably::Common
  helper :partial, :inform

  def source
    return if request['file'].nil? or request['file'] =~ /\.{2}/

    file = RAMAZE_SRC + request['file']
    if FileTest.file? file
      inform :info, "Showing source for #{file}"
      CodeRay.scan_file(file).html(:line_numbers => :inline)
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
  
  define_method('coderay.css') do
    response['Content-Type'] = 'text/css'
    CodeRay::Encoders[:html]::CSS.new.stylesheet
  end
  
  private

  def dir_listing dir
    li do
      span dir, :class => 'folder'
      Dir.chdir(dir) do
        if Dir['*'].any?
          ul do
            a '', :href => "##{File.expand_path('.').sub(RAMAZE_SRC,'')}"
            Dir['*'].each do |d|
              if FileTest.directory? d
                dir_listing d
              else
                file = File.expand_path(d).sub(RAMAZE_SRC,'')
                li do
                  span :class => 'file', :name => file do
                    a d, :href => "##{file}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

end

Ramaze.start :adapter => :mongrel, :boring => [/(js|gif|css)$/], :port => 3000