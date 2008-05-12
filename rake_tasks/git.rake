desc 'run specs and then git commit'
task 'git:commit' => [:default] do
  sh 'git commit'
end
