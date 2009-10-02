namespace :release do
  task :prepare => %w[jquery reversion authors gemspec]
  task :all => %w[release:github release:rubyforge release:gemcutter]

  desc 'Release on github'
  task :github => :prepare do
    name, version = GEMSPEC.name, GEMSPEC.version

    sh('git', 'add',
       'MANIFEST', 'doc/CHANGELOG', 'doc/AUTHORS',
       "#{name}.gemspec",
       'lib/proto/public/js/jquery.js',
       "lib/#{name}/version.rb")

    puts <<-INSTRUCTIONS
================================================================================

I added the relevant files, you can commit them, tag the commit, and push:

git commit -m 'Version #{version}'
git tag -a -m '#{version}' '#{version}'
git push

================================================================================
    INSTRUCTIONS
  end

  desc 'Release on rubyforge'
  task :rubyforge => ['release:prepare', :package] do
    name, version = GEMSPEC.name, GEMSPEC.version

    pkgs = Dir["pkg/#{name}-#{version}.{tgz,zip}"].map{|file|
      "rubyforge add_file #{name} #{name} '#{version}' '#{file}'"
    }

    puts <<-INSTRUCTIONS
================================================================================

To publish to rubyforge do following:

rubyforge login
rubyforge add_release #{name} #{name} '#{version}' pkg/#{name}-#{version}.gem

To publish the archives for distro packagers:

#{pkgs.join "\n"}

================================================================================
    INSTRUCTIONS
  end

  desc 'Release on gemcutter'
  task :gemcutter => ['release:prepare', :package] do
    name, version = GEMSPEC.name, GEMSPEC.version

    puts <<-INSTRUCTIONS
================================================================================

To publish to gemcutter do following:

gem push pkg/#{name}-#{version}.gem

================================================================================
    INSTRUCTIONS
  end
end
