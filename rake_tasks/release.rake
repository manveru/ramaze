task :release => ['doc/CHANGELOG', 'doc/README'] do
end

task 'git:tag' do
  require 'git'
  git = Git.open('.')
  git.add_tag GEMSPEC.version
end
