module Ramaze
  class Bin
    new([]).load_command(:start)

    # TODO: Make use of the status command and reuse the 'Command Line'.
    class Restart < Start
      DESC = 'Restart ramaze instance'
      HELP = <<-DOC
SYNOPSIS
  ramaze restart [options]

DESCRIPTION
  Will stop and restart a running ramaze instance if a corrseponding pidfile
  can be found.
  If no server is running already, new instance will be started.

  Options to this command are passed along to the start and stop commands.
  Please supply long flags to avoid ambiguity when the short flag name is the
  same.
  If the long flags are identical as well, we will pass the same option to both
  commands, as it can be assumed that their purpose is identical (for example
  see the --pid flag).

  You can give multiple pidfiles (if you don't supply the --pid flag), which
  will intelligently parse the port from the pidfile name <app>.<port>.pid format.
  In this mode of operation, the new application is started daemonized on the port.

USAGE
  ramaze restart
  ramaze restart --pid blog.pid
  ramaze restart --pid blog.pid --daemonize
  ramaze restart blog.7000.pid blog.7001.pid
  ramaze restart *.pid
      DOC

      def run(options)
        if pidfile = options[:pidfile]
          restart pidfile, options
        else
          pidfiles = @bin.args.dup
          @bin.args.clear

          pidfiles.each do |pidfile|
            restart Pathname(pidfile), options
          end
        end

        exit
      end

      def restart(pidfile, options)
        stop(pidfile)

        case pidfile.basename.to_s
        when /(\w+)\.(\d+)\.pid/
          start(options.merge(:pidfile => pidfile, :port => $2.to_i, :daemonize => true))
        else
          start(options.merge(:pidfile => pidfile))
        end
      end

      def stop(pidfile)
        Bin.new(@bin.args.dup).load_command(:stop) do |cmd|
          cmd.stop(pidfile)
        end
      rescue SystemExit
      end
    end
  end
end
