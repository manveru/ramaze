desc 'install all possible dependencies'
task :setup => [:gem_setup] do
  GemSetup.new :verbose => false do
    DEPENDENCIES.each do |name, options|
      gem(name, options)
    end

    DEVELOPMENT_DEPENDENCIES.each do |name, options|
      gem(name, options)
    end
  end
end
