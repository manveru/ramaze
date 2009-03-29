desc 'Run all bacon specs with pretty output'
task :bacon => :install_dependencies do
  require 'open3'
  require 'scanf'

  specs = PROJECT_SPECS

  some_failed = false
  total = specs.size
  len = specs.map{|s| s.size }.sort.last
  tt = ta = tf = te = 0

  red, yellow, green = "\e[31m%s\e[0m", "\e[33m%s\e[0m", "\e[32m%s\e[0m"
  left_format = "%4d/%d: %-#{len + 11}s"
  spec_format = "%d specifications (%d requirements), %d failures, %d errors"

  specs.each_with_index do |spec, idx|
    print(left_format % [idx + 1, total, spec])

    Open3.popen3(RUBY, spec) do |sin, sout, serr|
      out = sout.read
      err = serr.read

      ran = false

      out.each_line do |line|
        tests, assertions, failures, errors = all = line.scanf(spec_format)
        next unless all.any?
        ran = true
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

      puts(yellow % "       skipped") unless ran
    end
  end

  puts(spec_format % [tt, ta, tf, te])
  exit 1 if some_failed
end
