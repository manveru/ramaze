module Kernel
  def caller_lines size = 4
    file, line, meth = caller[1].scan(/(.*?):(\d+):in `(.*?)'/).first
    puts "#{file}:#{line} in #{meth}"

    lines = File.readlines(file)
    current = line.to_i - 1

    first = current - size
    first = first < 0 ? 0 : first

    last = current + size
    last = last > lines.size ? lines.size : last

    log = lines[first..last]

    log.each_with_index do |line, index|
      index = index + first + 1
      i = index.to_s.ljust(last.to_s.size)
      puts "#{i} #{index == current + 1 ? '=>' : '  '}| #{line}"
    end
  end
end
