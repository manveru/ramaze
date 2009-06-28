module Ramaze
  class Bin
    class Stop < Generic
      DESC = 'Stop currently running application'
      HELP = <<-DOC
SYNOPSIS
  ramaze stop [pidfile] [options]

DESCRIPTION
  Stop a currently running instance of your application.

USAGE
  ramaze stop blog.pid
      DOC

      def parser(o, options)
        pidfile = default_pidfile

        o.on("-P", "--pid FILE", "file PID is stored in (default: #{pidfile})"){|v|
          options[:pidfile] = Pathname(v).expand_path
        }
      end

      def run(options)
        if pidfile = options[:pidfile]
          stop pidfile
        else
          while pidfile = @bin.args.shift
            stop pidfile
          end
        end

        raise SystemExit, pidfile
      end

      def stop(possible_pid_file)
        unless pid_file = find_pid(possible_pid_file)
          warn "No Pidfile found! Cannot stop ramaze (may not be started)."
          exit 1
        end

        pid = File.read(pid_file).to_i
        puts "Stopping pid #{pid}"
        Process.kill("INT", pid)
        sleep 2

        if is_running?(pid)
          $stderr.puts "Process #{pid} did not die, forcing it with -9"
          Process.kill(9, pid)
          File.unlink(pid_file) if File.file?(pid_file)
          true
        else
          File.unlink(pid_file) if File.file?(pid_file)
          true
        end
      end
    end
  end
end
