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

        s.add_dependency('rake', '>=0.7.3')
        s.add_dependency('rack', '>=0.2.0')
        # s.required_ruby_version = '>= 1.8.5'

        s.files = (RDOC_FILES + %w[Rakefile] + Dir["{examples,bin,doc,spec,lib,rake_tasks}/**/*"]).uniq

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
