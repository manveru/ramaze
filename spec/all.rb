#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'pp'
require 'set'

begin
  require 'rubygems'
rescue LoadError
end

begin
  require 'systemu'
rescue LoadError
  puts "Please install systemu for better-looking results"

  # small drop-in replacement for systemu... far from perfect though, so please
  # install the library

  def systemu command
    stdout = `#{command} 2>&1`
    status, stdout, stderr = $?, stdout, ''
  end
end

class String
  { :red => 31,
    :green => 32,
    :yellow => 33,
  }.each do |key, value|
    define_method key do
      "\e[#{value}m" + self + "\e[0m"
    end
  end

  def /(str)
    File.join(self, str.to_s)
  end
end

class Array
  def commonize
    snips, rest = map{|s| [s[0,1], s[1..-1]]}.transpose
    if snips.uniq.size == 1
      rest.commonize
    else
      self
    end
  end

  def namize
    commonize.map do |e|
      dir = File.dirname(e)
      file = File.basename(e, File.extname(e))
      ( dir / file ).gsub(/^\.\//, '')
    end
  end
end

$stdout.sync = true

class SpecWrap
  def initialize(*files)
    @files = files.flatten
    @names = @files.namize
    @specs = Hash[*@files.zip(@names).flatten]
    @done = Set.new
  end

  def run
    @specs.sort_by{|s| s.last}.each do |file, name|
      spec = SpecFile.new(file, name, term_width)
      spec.run
      spec.short_summary
      @done << spec
    end

    @done.sort_by{|d| d.name}.each do |spec|
      puts(spec.long_summary) if spec.failed?
    end

    summarize
  end

  def summarize
    total_passed = @done.inject(0){|s,v| s + v.passed }
    total_failed = @done.inject(0){|s,v| s + v.failed }
    total_specs = total_failed + total_passed

    puts "#{total_specs} specifications, #{total_failed} failures"
    puts

    if total_failed.nonzero?
      failed = @done.select{|d| d.failed.nonzero? or d.passed.zero?}.map{|f| f.name.red }
      puts "These failed: #{failed.join(', ')}"
      exit 1
    else
      puts("No failing specifications, let's add some tests!")
    end
  end

  def term_width
    @names.sort_by{|s| s.size }.last.size
  end
end

class SpecFile
  attr_reader :file, :name, :passed, :failed

  def initialize file, name, term_width
    @file, @name, @term_width = file, name, term_width
    @inc = $:.map{|e| "-I#{e}" }.join(" ")
  end

  def run
    init
    execute
    parse
    done
    self
  end

  def init
    print "Running #@name... ".ljust(@term_width + 20)
  end

  def execute
    @status, @stdout, @stderr = systemu("ruby #@inc #@file")
  end

  def done
    @ran = true
  end

  def short_summary
    f = lambda{|n| n.to_s.rjust(3) }
    total = f[@passed + @failed] rescue nil
    failed, passed = f[@failed], f[@passed]
    color = :red
    if total_failure?
      text = 'total failure'
    elsif failed?
      text = "#{total} specs - #{failed} failed"
      if @stdout =~ /Usually you should not worry about this failure, just install the/
        lib = @stdout.scan(/^no such file to load -- (.*?)$/).flatten.first
        text = "needs #{lib}"
      end
    elsif succeeded?
      color = :green
      text = "#{total} specs - all passed"
    end

    text.strip!
    text = (' ' + text + ' ').center(24)
    text = "[#{text}]"

    puts(text.send(color))
  end

  def long_summary
    puts "[ #@name ]".center(80, '-'), "ExitStatus:".yellow
    pp @status
    puts "StdOut:".yellow, @stdout, "StdErr:".yellow, @stderr
  end

  def parse
    @passed = 0
    @failed = 0
    found = false
    @stdout.grep(/(\d+) specifications?, (\d+) failures?/)
    @passed, @failed = $1.to_i, $2.to_i
  end

  def failed?
    not succeeded?
  end

  def total_failure?
    succeeded? == nil
  end

  def succeeded?
    run unless @ran
    crits = [
      [@status.exitstatus.zero?, @stderr.empty?],
      [@passed, @failed],
      [@passed.nonzero?, @failed.zero?],
    ]
    crits.all?{|c| c.all? }
  rescue
    nil
  end
end

base = File.expand_path(File.dirname(__FILE__)/'ramaze')

files = Dir[base/'*.rb']
files += %w[template store].map{|dir| Dir[base/dir/'*.rb']}.flatten
files.dup.each do |file|
  dirname = base/File.basename(file, '.rb')
  if File.directory?(dirname)
    files.delete(file)
    files += Dir[dirname/'*.rb']
  else
    file
  end
end

wrap = SpecWrap.new(files)
wrap.run

=begin

total_specs = 0
total_fails = 0
failed      = {}

specs_dir = File.dirname(File.expand_path(__FILE__))
base = File.join(specs_dir, 'ramaze')

specs = Set.new(Dir[File.join(base, '*.rb')])

dirs = %w[adapter request template helper]
dirs.each do |dir|
  specs += Dir[File.join(base, dir, '*.rb')]
end

specs.each do |spec|
  specs.delete(spec) if dirs.include?(File.basename(spec, '.rb'))
end

width       = specs.sort_by{|s| s.size }.last.size

result_format = lambda do |str|
  str = " #{ str } ".center(22, '=')
  "[ #{str} ]"
end

inc = $:.map{|x|"-I#{x}"}.join(" ")

specs.each do |spec|
  print "Running #{spec}... ".ljust(width + 20)
  status, stdout, stderr = systemu("ruby #{inc} #{spec}")
  hash = {:status => status, :stdout => stdout, :stderr => stderr}

  if stdout =~ /Usually you should not worry about this failure, just install the/

    lib = stdout.scan(/^no such file to load -- (.*?)$/).flatten.first
    print result_format["needs #{lib}"].red

  elsif status.exitstatus.nonzero? or stdout.empty? or not stderr.empty?

    failed[spec] = hash
    print result_format['failed'].red

  else
    found = false
    stdout.each do |line|
      if line =~ /(\d+) specifications?, (\d+) failures?/
        found = true
        s, f = $1.to_i, $2.to_i
        ss, sf = s.to_s.rjust(3), f.to_s.rjust(3)

        total_specs += s
        total_fails += f

        message = "[ #{ss} specs - "

        if f.nonzero?
          failed[spec] = hash
          print((message << "#{sf} failed ]").red)
        else
          print((message << "all passed ]").green)
        end
      end
    end

    unless found
      print("[ please test standalone ]".red)
    end
  end
  puts
end

failed.each do |name, hash|
  status, stdout, stderr = hash.values_at(:status, :stdout, :stderr)

  puts "[ #{name} ]".center(80, '-')
  puts "ExitStatus:".yellow
  pp status
  puts
  puts "StdOut:".yellow
  puts stdout
  puts
  puts "StdErr:".yellow
  puts stderr
end

puts
puts "#{total_specs} specifications, #{total_fails} failures"
puts

if failed.empty?
  puts "No failing specifications, let's add some tests!"
  exit 0
else
  puts "These failed: #{failed.keys.join(', ')}"
  exit 1
end
=end
