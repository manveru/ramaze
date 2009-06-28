module Ramaze
  class Bin
    class Start < Generic
      DESC = 'Start a ramaze instance'
      HELP = <<-DOC
SYNOPSIS
  ramaze start [options]

DESCRIPTION
  Start a new instance of your application with the given options.
  If you try to daemonize, and a running instance is found corresponding to an
  existing pidfile, nothing will be done.
  So to daemonize multiple instances, you will have to run them on different
  ports and use a different pidfile for each.

  The --cluster flag creates different pidfiles automatically in a way that can
  be reused for `ramaze restart`. It works similar to following shell script:

  for n in {1..5}; do
    port=`echo 7000 + $n | bc`
    ramaze start -p $port -P "bar.$port.pid" -D
  done

USAGE
  ramaze start -s mongrel -o localhost -p 7070 -D
  ramaze start --cluster 5 --server mongrel
      DOC

      def parser(o, options)
        pidfile = default_pidfile
        options[:server] = server = 'webrick'
        options[:host] = host = '0.0.0.0'
        options[:port] = port = 7000

        o.on('-s', '--server SERVER', "Use given SERVER (default: #{server})"){|v|
          options[:server] = v
        }
        o.on('-o', '--host HOST', "listen on HOST (default: #{host})"){|v|
          options[:host] = v
        }
        o.on('-p', '--port PORT', Integer, "use PORT (default: #{port})"){|v|
          options[:port] = v
        }
        o.on("-D", "--daemonize", "run daemonized in the background"){|v|
          options[:daemonize] = v
        }
        o.on("-P", "--pid FILE", "file to store PID (default: #{pidfile})"){|v|
          options[:pidfile] = Pathname(v).expand_path
        }
        o.on('-c', '--cluster NUMBER', Integer,
             'start NUMBER instances on PORT+N',
             'This implies daemonizing and creates a pidfile for every instance'){|v|
          options[:cluster] = v
        }
      end

      def run(options)
        start(options)
        exit
      end

      private

      def start(options)
        if cluster = options[:cluster]
          options[:daemonize] = true
          original_port = options[:port]
          original_pidfile = (options[:pidfile] || default_pidfile).to_s

          cluster.times do |n|
            port = original_port + n
            pidfile = Pathname(original_pidfile.split('.').join(".#{port}."))

            rack_args = assemble_args(options.merge(:port => port, :pidfile => pidfile))
            start_rackup(rack_args)
          end
        else
          rack_args = assemble_args(options)
          start_rackup(rack_args)
        end
      end

      def assemble_args(options)
        app_name = default_pidfile.sub(/\.pid$/,'')

        host   = (options[:host] || ramaze_option.host).to_s
        port   = (options[:port] || ramaze_option.port).to_i
        server = (options[:server] || ramaze_option[:adapter, :handler]).to_s

        rack_args = @bin.args
        rack_args += ['--port', port, '--host', host, '--server', server]

        if options[:daemonize]
          pidfile = options[:pidfile] || default_pidfile
          puts "Starting daemon with pidfile: #{pidfile}"
          rack_args += ['--pid', pidfile.to_s]
          rack_args += ['--daemonize']

          if check_running?(pidfile)
            warn "Ramaze is already running with pidfile: #{pidfile}"
            exit 1
          end
        end

        rack_args
      end

      def start_rackup(rackup_arguments)
        rack_args = rackup_arguments.flatten.map{|arg| arg.to_s }
        rackup = rackup_path.to_s

        if is_windows?
          puts ['ruby', rackup, "config.ru", *rack_args].join(' ')
          system('ruby', rackup, 'config.ru', *rack_args)
        else
          puts [rackup, "config.ru", *rack_args].join(' ')
          system(rackup, "config.ru", *rack_args)
        end
      end

      def ramaze_option
        require_ramaze
        Ramaze.options
      end
    end
  end
end
