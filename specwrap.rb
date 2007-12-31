#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

%w[ pp set systemu scanf ].each{|lib| require lib}

module PrettySpec
  STDOUT_MOCK = []
  class << STDOUT_MOCK
    def print(*e) concat(e) end
    def puts(*e) concat(e) end
    def flush; end
  end
  STDERR_MOCK = STDOUT_MOCK.clone
  RESULT_FORMAT = "%d tests, %d assertions, %d failures, %d errors"
  PATH = File.join(File.dirname(__FILE__), 'lib')

  class Wrapper
    attr_reader :exit_status, :file, :stdout, :stderr, :failed, :passed, :total, :dependency

    def initialize(file)
      @file = file
      @stdout, @stderr = STDOUT_MOCK.clone, STDERR_MOCK.clone
      @passed = @failed = @total = 0
      @dependency = @fatal = false
      @error = []
    end
    
    def run
      run_standalone = true

      if run_standalone
        @process, @stdout, @stderr = systemu("ruby -I #{PATH} #{file}")
        @stdout, @stderr = @stdout.split("\n"), @stderr.split("\n")
      else
        load(@file)
      end

      @result = @stdout.find{|l|
        @tests, @assertions, @failures, @errors = l.scanf(RESULT_FORMAT)
        @tests
      }
      # 1 tests, 0 assertions, 0 failures, 1 errors
      @total, @failed = @assertions, (@failures + @errors)
      @passed = @total - @failed
      self

    rescue TypeError, RuntimeError, NoMethodError => ex
      @fatal = ex
      @error << [ex, file, @process, @stdout, @stderr]
      self
    end

    def failed?
      @fatal or @total == 0 or @failed > 0
    end

    def fatal?
      @fatal
    end

    def dependency?
      @dependency = @stdout.join("\n")[/Can't run .*?: no such file to load -- (.*?)[\s$]/, 1]
    end

    def error_report
      print "Process: ".yellow
      puts @process
      puts "StdOut: ".green
      puts @stdout
      puts "StdErr: ".red
      puts @stderr
    end
  end

  class Summary
    attr_accessor :wrappers, :files

    def initialize
      @wrappers = []
      @files = []
    end

    def small_status
      total, failed, passed = 0, 0, 0
      @wrappers.each do |wrapper|
        failed += wrapper.failed
        passed += wrapper.passed
        total += wrapper.total
      end

      "#{total} examples: #{passed} passed, #{failed} failed"
    end

    def run_long
      require 'lib/ramaze/snippets/string/color.rb'
      $stdout.sync = true

      @files = @files.flatten.uniq.sort.compact
      @files = files
      total = @files.size
      format = "(%#{total.to_s.size}d/#{total}) %s "
      pass_format = "%4d total | %4d passed".green
      fail_format = "%4d total | %4d failed".red
      fatal_format = "Fatal failure".red
      dependency_format = "needs: %s".red
      left_indent = @files.sort_by{|s| s.size}.last.size + 10
      out = lambda{|s| puts "[ #{s.to_s.center(33)} ]"}

      @files.each_with_index do |file, idx|
        @wrappers << sw = PrettySpec::Wrapper.new(file)

        str = format % [idx + 1, file]
        print str.ljust(left_indent)

        sw.run

        if sw.dependency?
          out[dependency_format % sw.dependency]
        elsif sw.fatal?
          out[fatal_format]
          puts sw.error_report
        elsif sw.failed?
          out[fail_format % [sw.total, sw.failed]]
          puts sw.error_report
        else
          out[pass_format % [sw.total, sw.passed]]
        end
      end

      final_summary
    end

    def final_summary
      failed_wrappers = @wrappers.select{|w| w.failed? }
      if failed_wrappers.empty?
        true
      else
        files = failed_wrappers.map{|w| w.file}.join(' ')
        puts "Following files failed: #{files}"
        failed_wrappers.all?{|w| w.dependency? }
      end
    end
  end
end

files = Dir['spec/{ramaze,snippets,examples,contrib}/**/*.rb']
files += Dir['examples/**/spec/**/*.rb']
files.delete 'spec/ramaze/adapter.rb'

summary = PrettySpec::Summary.new
summary.files = files

if summary.run_long
  puts "No (for you important) specs failed, let's add some! :)"
  exit 0
else
  exit 1
end
