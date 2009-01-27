#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rake'

desc 'run specs'
task 'spec' do
  require 'open3'

  specs = Dir['spec/{ramaze,snippets}/**/*.rb']

  total = specs.size
  len = specs.sort.last.size
  left_format = "%4d/%d: %-#{len + 12}s"

  red, green = "\e[31m%s\e[0m", "\e[32m%s\e[0m"

  specs.each_with_index do |spec, idx|
    print(left_format % [idx + 1, total, spec])

    Open3.popen3("#{RUBY} #{spec}") do |sin, sout, serr|
      out = sout.read
      err = serr.read

      md = out.match(/(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/)
      tests, assertions, failures, errors = all = md.captures.map{|c| c.to_i }

      if failures + errors > 0
        puts((red % "%6d tests, %d assertions, %d failures, %d errors") % all)
        puts out
        puts err
      else
        puts((green % "%6d passed") % tests)
      end
    end
  end
end
