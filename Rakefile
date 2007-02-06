require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'pp'
include FileUtils

$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'ramaze/version'

AUTHOR = "manveru"
EMAIL = "m.fellinger@gmail.com"
DESCRIPTION = "Ramaze tries to be a very simple Webframework without the voodoo"
HOMEPATH = 'http://ramaze.rubyforge.org'
BIN_FILES = %w( ramaze )

BASEDIR = File.dirname(__FILE__)

NAME = "ramaze"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Ramaze::VERSION + (REV ? ".#{REV}" : ""))
CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  pkg
  rdoc
]
RDOC_OPTS = %w[
  --all
  --quiet
  --op rdoc
  --line-numbers
  --inline-source
  --main "doc/README"
  --opname index.html
  --title "Ramze documentation"
  --exclude "^(_darcs|spec|examples|bin|pkg)/"
  --exclude "lib/proto"
  --include "doc"
  --accessor "trait"
]

POST_INSTALL_MESSAGE = %{
#{'=' * 60}

Thank you for installing Ramaze!
You can now do following:

* Create a new project using the `ramaze' command:
    ramaze --create yourproject

* Browse and try the Examples in
    #{File.join(Gem.path, 'gems', 'ramaze-' + VERS, 'examples')}

#{'=' * 60}
}.strip

desc "Packages up ramaze gem."
task :default => [:test]

desc "clean up temporary files and gems"
task :package => [:clean]

spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = true
        s.extra_rdoc_files = ["doc/README", "doc/CHANGELOG"]
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

        s.add_dependency('rake', '>=0.7.1')
        #s.required_ruby_version = '>= 1.8.2'

        s.files = %w(doc/COPYING doc/TODO doc/README doc/CHANGELOG Rakefile) +
          Dir["{examples,bin,doc,spec,lib}/**/*"]

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

desc "sanitize the code and darcs record"
task :record => ['fix-end-spaces', 'add-copyright'] do
  system("darcs", "record")
end

desc "create the doc/changes.xml"
task 'changes-xml' do
  File.open('doc/changes.xml', 'w+') do |f|
    f.print(`darcs changes --xml`)
  end
end

desc "create the doc/changes.txt"
task 'changes-text' do
  File.open('doc/changes.txt', 'w+') do |f|
    f.print(`darcs changes --human-readable`)
  end
end

desc "create both doc/changes.txt and doc/changes.xml"
task :changes => ['changes-xml', 'changes-text'] do
  puts(`darcs changes`.split("\n").first(25))
end

desc "copy the doc/changes.txt to doc/CHANGELOG"
task :changelog => :changes do
  cp 'doc/changes.txt', 'doc/CHANGELOG'
end

desc "add copyright to all .rb files in the distribution"
task 'add-copyright' do
  puts "adding copyright to files that don't have it currently"
  Dir['{lib,test}/**/*{.rb}'].each do |file|
    lines = File.readlines(file).map{|l| l.chomp}
    copyright = [
      "#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com",
      "# All files in this distribution are subject to the terms of the Ruby license."
    ]
    unless lines.first(2) == copyright
      puts "fixing #{file}"
      File.open(file, 'w+') do |f|
        (copyright + lines).each do |line|
          f.puts(line)
        end
      end
    end
  end
end

task :rcov_dir do
  mkdir_p 'doc/output/tools/rcov/'
end

require 'spec/rake/spectask'
desc "Generate HTML coverage report"
Spec::Rake::SpecTask.new(:rcov_summary => :rcov_dir) do |t|
  t.spec_files = FileList['test/tc_adapter.rb']
  t.spec_opts = ["--format", "html"]
  t.out = 'doc/output/tools/rcov/test.html'
  t.fail_on_error = false
end

desc "run the specs and clean up afterwards"
task :test do
  sh "ruby #{File.dirname(__FILE__)}/spec/spec_all.rb"
  sh "rake clean"
end

desc "generate rdoc"
task :rdoc => :clean do
  sh "rdoc #{RDOC_OPTS.join(' ')} lib doc doc/README doc/CHANGELOG"
end

desc "generate improved allison-rdoc"
task :allison => :clean do
  opts = RDOC_OPTS
  opts << %w[--template 'doc/allison/allison.rb']
  sh "rdoc #{RDOC_OPTS.join(' ')} lib doc/README doc/CHANGELOG"
end

desc "doc/README to html"
Rake::RDocTask.new('gen-readme2html') do |rd|
  rd.options = %w[
    --quiet
    --opname readme.html
  ]

  rd.rdoc_dir = 'readme'
  rd.rdoc_files = ['doc/README']
  rd.main = 'doc/README'
  rd.title = "Ramaze documentation"
end

desc "doc/README to doc/README.html"
task 'readme2html' => 'gen-readme2html' do
  FileUtils.cp('readme/files/doc/README.html', 'doc/README.html')
  FileUtils.rm_rf('readme')
end

desc "list all still undocumented methods"
task :undocumented do
  files = Dir[File.join('lib', '**', '*.rb')]

  files.each do |file|
    puts file
    lines_till_here = []
    lines = File.readlines(file).map{|line| line.chomp}

    lines.each do |line|
      if line =~ /def /
        indent = line =~ /[^\s]/
        e = lines_till_here.reverse.find{|l| l =~ /end/}
        i = lines_till_here.reverse.index(e)
        lines_till_here = lines_till_here[-(i + 1)..-1] if i
        unless lines_till_here.any?{|l| l =~ /^\s*#/} or lines_till_here.empty?
          puts lines_till_here
          puts line
          puts "#{' ' * indent}..."
          puts e
        end
      lines_till_here.clear
      end
      lines_till_here << line
    end
  end
end

desc "show a todolist from all the TODO tags in the source"
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
        print '  ' unless l =~ /^-/
        puts l
        lastline = lineno
      end
    end
  end
end

desc "generate doc/TODO from the TODO tags in the source"
task 'todolist' do
  list = `rake todo`.split("\n")[2..-1]
  tasks = {}
  current = nil

  list.map do |line|
    if line =~ /TODO/ or line.empty?
    elsif line =~ /^vim/
      current = line.split[1]
      tasks[current] = []
    else
      tasks[current] << line
    end
  end

  lines = tasks.map{ |name, items| [name, items, ''] }.flatten
  lines.pop

  File.open(File.join('doc', 'TODO'), 'w+') do |f|
    f.puts "This list is programmaticly generated by `rake todolist`"
    f.puts "If you want to add/remove items from the list, change them at the"
    f.puts "position specified in the list."
    f.puts
    f.puts(lines)
  end
end

desc "show how many patches we made so far"
task :patchsize do
  size = `darcs changes`.split("\n").reject{|l| l =~ /^\s/ or l.empty?}.size
  puts "currently we got #{size} patches"
  puts "shall i now play some Death-Metal for you?" if size == 666
end

desc "remove those annoying spaces at the end of lines"
task 'fix-end-spaces' do
  Dir['{lib,test}/**/*.rb'].each do |file|
    lines = File.readlines(file)
    new = lines.dup
    lines.each_with_index do |line, i|
      if line =~ /\s+\n/
        puts "fixing #{file}:#{i + 1}"
        p line
        new[i] = line.rstrip
      end
    end

    unless new == lines
      File.open(file, 'w+') do |f|
        new.each do |line|
          f.puts(line)
        end
      end
    end
  end
end

desc "opens a simple readline that makes making requests easier"
task 'request' do
  ARGV.clear
  require 'open-uri'
  require 'pp'

  loop do
    print 'do request? [enter] '
    gets
    begin
      pp open('http://localhost:7000/xxx').read
    rescue Object => ex
      puts ex
    end
  end
end
