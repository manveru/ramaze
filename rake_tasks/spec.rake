#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rake'

desc 'run specs'
task 'spec' do
  require 'open3'
  require 'scanf'

  specs = Dir['spec/{ramaze,snippets}/**/*.rb']

  some_failed = false
  total = specs.size
  len = specs.map{|s| s.size }.sort.last
  tt = ta = tf = te = 0

  left_format = "%4d/%d: %-#{len + 11}s"
  red, green = "\e[31m%s\e[0m", "\e[32m%s\e[0m"
  spec_format = "%d specifications (%d requirements), %d failures, %d errors"

  specs.each_with_index do |spec, idx|
    print(left_format % [idx + 1, total, spec])

    Open3.popen3("#{RUBY} #{spec}") do |sin, sout, serr|
      out = sout.read
      err = serr.read

      out.each_line do |line|
        tests, assertions, failures, errors = all = line.scanf(spec_format)
        next unless all.any?
        tt += tests; ta += assertions; tf += failures; te += errors

        if tests == 0 || failures + errors > 0
          puts((red % spec_format) % all)
          puts out
          puts err
        else
          puts((green % "%6d passed") % tests)
        end

        break
      end
    end
  end

  puts(spec_format % [tt, ta, tf, te])
  exit 1 if some_failed
end
