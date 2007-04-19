#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper/wrap'

base = File.expand_path(File.dirname(__FILE__)/'ramaze')

files = Dir[base/'*.rb']
files += %w[template store].map{|dir| Dir[base/dir/'*.rb']}.flatten
files.dup.each do |file|
  dirname = base/File.basename(file, '.rb')
  if File.directory?(dirname)
    files.delete(file)
    files += Dir[dirname/'*.rb']
  else
    file
  end
end

wrap = SpecWrap.new(files)
wrap.run
