desc 'Apply a patch bundle to darcs repo'
task :apply do
  bundle = ENV['BUNDLE'] || ENV['bundle'] || 'bundle'
  sh "darcs apply -v --reply=ramaze@googlegroups.com #{bundle}"
end
