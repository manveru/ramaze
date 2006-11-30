require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'ramaze', 'version')

AUTHOR = "manveru"
EMAIL = "m.fellinger@gmail.com"
DESCRIPTION = "Ramaze tries to be a very simple Webframework without the voodoo"
HOMEPATH = 'http://ramaze.rubyforge.org'
BIN_FILES = %w( ramaze )

BASEDIR = File.dirname(__FILE__)

NAME = "ramaze"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Ramaze::VERSION + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "ramaze documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "doc/README",
    "--inline-source"]

desc "Packages up ramaze gem."
task :default => [:test]
task :package => [:clean]

task :test do
  system("ruby",  File.dirname(__FILE__) + '/lib/test/all_tests.rb')
end

spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = true
        s.extra_rdoc_files = ["doc/README", "doc/CHANGELOG"]
        s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)/']
        s.summary = DESCRIPTION
        s.description = DESCRIPTION
        s.author = AUTHOR
        s.email = EMAIL
        s.homepage = HOMEPATH
        s.executables = BIN_FILES
        s.bindir = "bin"
        s.require_path = "lib"

        #s.add_dependency('activesupport', '>=1.3.1')
        #s.required_ruby_version = '>= 1.8.2'

        s.files = %w(doc/README doc/CHANGELOG Rakefile) +
          Dir.glob("{bin,doc,test,lib,templates,extras,website,script}/**/*") + 
          Dir.glob("ext/**/*.{h,c,rb}") +
          Dir.glob("examples/**/*.rb") +
          Dir.glob("tools/*.rb")
        
        # s.extensions = FileList["ext/**/extconf.rb"].to_a
    end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = true
    p.gem_spec = spec
end

task :install do
  name = "#{NAME}-#{VERS}.gem"
  sh %{rake package}
  sh %{sudo gem install pkg/#{name}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

task :rcov do
  Dir[File.join(BASEDIR, 'test', 'tc_*.rb')].each do |file|
    sh %{rcov #{file}}
  end
end

task :rdoc do
  dirs = %w[ lib doc ].join(' ')
  sh %{rdoc --op rdoc -d --main doc/README #{dirs}}
end

task :todo do
  files = Dir[File.join(BASEDIR, '{lib,test}', '**/*.rb')]

  files.each do |file|
    lastline = todo = comment = long_comment = false

    File.readlines(file).each_with_index do |line, lineno|
      lineno += 1
      comment = line =~ /^\s*?#.*?$/ 
      long_comment = line =~ /^=begin/
      long_comment = line =~ /^=end/
      todo = true if line =~ /TODO/ and (long_comment or comment)
      todo = false if line.gsub('#', '').strip.empty? 
      todo = false unless comment or long_comment
      if todo
        unless lastline and lastline + 1 == lineno
          puts
          puts "vim #{file} +#{lineno}"
        end

        l = line.strip.gsub(/^#\s*/, '')
        if line =~ /TODO/
          puts "\t#{l}"
        else
          puts "\t\t#{l}"
        end
        lastline = lineno
      end
    end
  end
end
