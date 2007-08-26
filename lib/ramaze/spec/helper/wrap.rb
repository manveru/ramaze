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
    unless snips.uniq.size != 1 or rest.any?{|r| File.basename(r) == r}
      rest.commonize
    else
      self.map{|e| e.gsub(/^\//, '')}
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

    puts "#{total_specs} examples, #{total_failed} failures"
    puts

    if total_failed.nonzero?
      failed = @done.select{|d| d.failed.nonzero? or d.passed.zero?}.map{|f| f.name.red }
      puts "These failed: #{failed.join(', ')}"
      exit 1
    else
      puts("No failing examples, let's add some tests!")
    end
  end

  def term_width
    @names.sort_by{|s| s.size }.last.size
  end
end

class SpecFile
  attr_reader :file, :name, :passed, :failed, :mark_passed

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
    width = 22

    if total_failure?
      text = 'total failure'.center(width)
    elsif failed?
      text = "#{total} specs - #{failed} failed".rjust(width)
      if @stdout =~ /Usually you should not worry about this failure, just install the/
        lib = @stdout.scan(/^no such file to load -- (.*?)$/).flatten.first
        text = "needs #{lib}".center(width)
        @mark_passed = true
      end
    elsif (not @mark_passed) and succeeded?
      color = :green
      text = "#{total} specs - all passed".rjust(width)
    end

    puts "[ #{text.send(color)} ]"
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
    @stdout.grep(/(\d+) examples?, (\d+) failures?/)
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
    return @mark_passed unless @mark_passed.nil?
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
