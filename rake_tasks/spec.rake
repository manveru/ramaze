#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rake'
require 'ramaze/spec/helper/layout'
require 'lib/ramaze/snippets/string/DIVIDE'

SPEC_BASE = File.expand_path('spec')
EXAMPLE_BASE = File.expand_path('examples')
SNIPPETS_BASE = File.expand_path('snippets')
# ignore files with these paths
ignores = [ './*', './helper/*', './ramaze/adapter.rb', './ramaze/request.rb', ]

files = Dir[SPEC_BASE/'**'/'*.rb'] + 
        Dir[EXAMPLE_BASE/'**/spec'/'*.rb']
        Dir[SNIPPETS_BASE/'**/*.rb']
ignores.each do |ignore|
  ignore_files = Dir[SPEC_BASE/ignore]
  ignore_files.each do |ignore_file|
    files.delete File.expand_path(ignore_file)
  end
end

files.sort!

spec_layout = Hash.new{|h,k| h[k] = []}

files.each do |file|
  name = file.gsub(/^(#{SPEC_BASE}|#{EXAMPLE_BASE})/, '.')
  dir_name = File.dirname(name)[2..-1]
  task_name = ([:test] + dir_name.split('/')).join(':')
  spec_layout[task_name] << file
end

spec_layout.each do |task_name, specs|

  desc task_name
  task task_name => [:clean] do
    wrap = SpecWrap.new(*specs)
    wrap.run
  end
end

desc "Test all"
task "test:all" => [:clean] do
  wrap = SpecWrap.new(*spec_layout.values.flatten)
  wrap.run
end
