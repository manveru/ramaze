#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'pp'

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

begin
  require 'term/ansicolor'
  class String
    include Term::ANSIColor
  end
rescue LoadError
  puts "Please install term-ansicolor for better-looking results"

  class String

    # this will be set in case term/ansicolor cannot be
    # required, just makes colorless output

    def red() self end

    # this will be set in case term/ansicolor cannot be
    # required, just makes colorless output

    def green() self end
  end
end

$stdout.sync = true

total_specs = 0
total_fails = 0
failed      = {}
specs       = Dir[File.join('spec', 'tc_*.rb')].sort
width       = specs.sort_by{|s| s.size }.last.size

result_format = lambda do |str|
  str = " #{ str } ".center(22, '=')
  "[ #{str} ]"
end

specs.each do |spec|
  print "Running #{spec}... ".ljust(width + 20)
  status, stdout, stderr = systemu("ruby #{spec}")
  hash = {:status => status, :stdout => stdout, :stderr => stderr}

  if stdout =~ /Usually you should not worry about this failure, just install the/

    lib = stdout.scan(/^no such file to load -- (.*?)$/).flatten.first
    print result_format["needs #{lib}"].red

  elsif status.exitstatus.nonzero? or stdout.empty? or not stderr.empty?

    failed[spec] = hash
    print result_format['failed'].red

  else
    stdout.each do |line|
      if line =~ /(\d+) specifications?, (\d+) failures?/
        s, f = $1.to_i, $2.to_i
        ss, sf = s.to_s.rjust(3), f.to_s.rjust(3)

        total_specs += s
        total_fails += f

        message = "[ #{ss} specs - "

        if f.nonzero?
          failed[spec] = hash
          print((message << "#{ss} failed ]").red)
        else
          print((message << "all passed ]").green)
        end
      end
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
  puts
else
  puts "These failed: #{failed.keys.join(', ')}"
end
