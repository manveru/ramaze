desc 'Generate YARD documentation'
task :ydoc => :clean do
  sh('yardoc -o ydoc -r README.md')
end

desc "generate rdoc"
task :rdoc => [:clean] do
  sh "rdoc #{(RDOC_OPTS + RDOC_FILES).join(' ')}"
end

desc "generate improved allison-rdoc"
task :allison => :clean do
  opts = RDOC_OPTS
  path = `allison --path`.strip
  raise LoadError, "Please `gem install allison` first" if $?.exitstatus == 127
  opts << %W[--template '#{path}']
  sh "rdoc #{(RDOC_OPTS + RDOC_FILES).join(' ')}"
end
