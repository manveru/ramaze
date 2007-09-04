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
load 'rake_tasks/conf.rake'
load 'rake_tasks/gem.rake'
load 'rake_tasks/maintenance.rake'
load 'rake_tasks/spec.rake'
load 'rake_tasks/coverage.rake'

task :default => ['test:all']
task :test => ['test:all']

desc "sanitize the code and darcs record"
task :record => ['fix-end-spaces', 'add-copyright'] do
  sh "darcs record"
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

desc "generate rdoc"
task :rdoc => [:clean, :readme2html] do
  sh "rdoc #{(RDOC_OPTS + RDOC_FILES).join(' ')}"
end

desc "generate improved allison-rdoc"
task :allison => :clean do
  opts = RDOC_OPTS
  path = `allison --path`.strip
  raise LoadError, "Please `gem install allison` first" if $?.exitstatus == 127
  opts << %W[--template '#{path}']
  sh "rdoc #{(RDOC_OPTS + RDOC_FILES).join(' ')}"
end

desc "create bzip2 and tarball"
task :distribute => :gem do
  sh "rm -rf pkg/ramaze-#{VERS}"
  sh "mkdir -p pkg/ramaze-#{VERS}"
  sh "cp -r {bin,doc,lib,examples,spec,Rakefile,rake_tasks} pkg/ramaze-#{VERS}/"

  Dir.chdir('pkg') do |pwd|
    sh "tar -zcvf ramaze-#{VERS}.tar.gz ramaze-#{VERS}"
    sh "tar -jcvf ramaze-#{VERS}.tar.bz2 ramaze-#{VERS}"
  end

  sh "rm -rf pkg/ramaze-#{VERS}"
end

desc "show a todolist from all the TODO tags in the source"
task :todo do
  files = Dir[File.join(BASEDIR, '{lib,spec}', '**/*.rb')]

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

desc "show how many patches we made so far"
task :patchsize do
  patches = `darcs changes --reverse`.split("\n")
  size = patches.reject{|l| l =~ /^\s/ or l.empty?}.size
  puts "currently we have #{size} patches"
  puts "shall i now play some Death-Metal for you?" if size == 666
  days = (Time.now - Time.parse(patches[0])) / (3600*24)
  puts "#{days.round} days since init, avg #{"%4.2f" % (size/days)} patches per day"
end

desc "show who made how many patches"
task :patchstat do
  authors.sort_by{|k,v| -v[:patches]}.each do |name, author|
    puts "#{name}  #{author[:patches]}"
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

desc "runs all the testdocs (not functional yet)"
task "testdoc" do
  require '../testdoc/lib/testdoc'
  Dir['lib/ramaze/helper/*.rb'].each do |file|
    p file
    begin
      require file
      TestDoc.rspec_run(file)
    rescue Object => ex
      puts ex
    end
  end
end

desc 'listing of available traits per class/module'
task 'traits' do
  nodes = Hash.new{|h,k| h[k] = []}
  Dir['lib/**/*.rb'].each do |file|
    content = File.read(file)
    traits = content.grep(/^\s*trait\s*:/)
    traits.each do |trait|
      space = content[0..content.index(trait)].scan(/^\s*(?:class|module)\s+(.*)$/)
      space = space.flatten.join('::')
      nodes[space] << trait.strip
    end
  end

  nodes.each do |space, traits|
    puts space
    traits.each do |trait|
      print '  ', trait, "\n"
    end
    puts
  end
end
