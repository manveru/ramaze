desc 'install all possible dependencies'
task :setup => [:gem_setup] do
  GemSetup.new :verbose => true do
    setup_gemspec GEMSPEC
  end
end
