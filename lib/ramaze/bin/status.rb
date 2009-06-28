module Ramaze
  class Bin
    class Status < Generic
      DESC = 'Show status of running application'
      HELP = <<-DOC
SYNOPSIS
  ramaze status [pidfile] [options]

DESCRIPTION
  Show status of a running application instance. This command tries to find out
  as much as possible about your process, but may only work on POSIX and
  windows systems.
  If there is no detailed data available, it tries to use `ps` to display some
  basic information.

USAGE
  ramaze status -P blog.pid
  ramaze status *.pid
      DOC

      def parser(o, options)
        pidfile = default_pidfile

        o.on("-P", "--pid FILE", "file to store PID in (default: #{pidfile})"){|v|
          options[:pidfile] = Pathname(v).expand_path
        }
      end

      def run(options)
        if pidfile = options[:pidfile]
          status pidfile
        else
          @bin.args.dup.each do |pidfile|
            status Pathname(pidfile).expand_path
          end
        end

        exit
      end

      private

      def status(possible_pid_file)
        unless pid_file = find_pid(possible_pid_file)
          warn "No Pidfile found! Ramaze may not be started."
          exit 1
        end

        @pid = pid_in(pid_file)
        puts "Pidfile #{pid_file} found, PID is #{@pid}"

        unless is_running?(@pid)
          warn "PID #{@pid} is not running"
          exit 1
        end

        status_on_windows ||
          status_on_posix ||
          status_fallback
      end

      def status_on_windows
        return unless is_windows?

        query   = "select * from win32_process where ProcessId = #{@pid}"
        wmi     = WIN32OLE.connect("winmgmts://")
        process = wmi.ExecQuery(query).first

        puts "Ramaze is running!"
        status_puts 'Name',         process.Name
        status_puts 'Command Line', process.CommandLine
        status_puts 'Virtual Size', process.VirtualSize
        status_puts 'Started',      process.CreationDate
        status_puts 'Exec Path',    process.ExecutablePath
        status_puts 'Status',       process.Status
        true
      end

      def status_on_posix
        proc_dir = Pathname('/proc')

        # Check for /proc
        if proc_dir.directory?
          proc_pid = proc_dir.join(@pid.to_s)
          stat_file = proc_pid.join('stat')

          # If we have a "stat" file, we'll assume linux and get as much info
          # as we can
          if stat_file.file?
            stats = stat_file.read.split

            puts "Ramaze is running!"
            status_puts 'Command Line', (proc_pid+'cmdline').read.split("\0").join(' ')
            status_puts 'Virtual Size', "%f k" % (stats[22].to_i / 1024)
            status_puts 'Started', proc_pid.mtime
            status_puts 'Exec Path', (proc_pid+'exe').readlink
            status_puts 'Status', stats[2]
            return true
          end
        end

        # Fallthrough status, just print a ps
        puts "Ramaze process #{@pid} is running!"
        puts `ps l #{@pid}`
        true
      rescue Errno::ENOENT # what, no ps!?
        puts "No further information available"
      end

      def status_puts(name, value)
        puts("\t%s: %s" % [name, value])
      end
    end
  end
end
