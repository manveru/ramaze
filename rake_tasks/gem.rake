spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = true
        s.extra_rdoc_files = RDOC_FILES
        s.rdoc_options += RDOC_OPTS
        s.summary = DESCRIPTION
        s.description = DESCRIPTION
        s.author = AUTHOR
        s.email = EMAIL
        s.homepage = HOMEPATH
        s.executables = BIN_FILES
        s.bindir = "bin"
        s.require_path = "lib"
        s.post_install_message = POST_INSTALL_MESSAGE

        DEPENDENCIES.each do |lib, ver|
          s.add_dependency(lib, ver)
        end

        s.files = (RDOC_FILES + %w[Rakefile README] + Dir["{examples,bin,doc,spec,lib,rake_tasks}/**/*"]).uniq

        # s.required_ruby_version = '>= 1.8.5'
        # s.extensions = FileList["ext/**/extconf.rb"].to_a
    end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = true
    p.gem_spec = spec
end

desc "package and install ramaze"
task :install do
  name = "#{NAME}-#{VERS}.gem"
  sh %{rake package}
  sh %{sudo gem install pkg/#{name}}
end

desc "uninstall the ramaze gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

desc "Create an updated version of /ramaze.gemspec"
task :gemspec do
  gemspec = <<-OUT.strip
Gem::Specification.new do |s|
  s.name = %name%
  s.version = %version%

  s.summary = %summary%
  s.description = %description%
  s.platform = %platform%
  s.has_rdoc = %has_rdoc%
  s.author = %author%
  s.email = %email%
  s.homepage = %homepage%
  s.executables = %executables%
  s.bindir = %bindir%
  s.require_path = %require_path%
  s.post_install_message = %post_install_message%

  %dependencies%

  %files%
end
  OUT

  gemspec.gsub!(/%(\w+)%/) do
    case key = $1
    when 'version'
      spec.version.to_s.dump
    when 'dependencies'
      DEPENDENCIES.map{|l, v|
        "s.add_dependency(%p, %p)" % [l, v]
      }.join("\n  ")
    else
      spec.send($1).pretty_inspect.strip
    end
  end

  File.open("#{NAME}.gemspec", 'w+'){|file| file.puts(gemspec) }
end
