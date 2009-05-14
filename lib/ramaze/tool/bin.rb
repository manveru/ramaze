#!/usr/bin/env ruby
### This module offers the functionality to start, stop, restart, create,
### Check status, or run a console of a ramaze application
### see ramaze -h for usage
module Ramaze
  module Tool
    module Bin
      module Helpers # Helper methods {{{

        def default_pidfile # {{{
          return @default_pidfile if @default_pidfile
          require "pathname"
          @default_pidfile = (Pathname.new(".").expand_path.basename.to_s + ".pid").strip
        end # }}}

        # We're really only concerned about win32ole, so we focus our check on its
        # ability to load that
        def is_windows?  # {{{
          return @is_win if @is_win
          begin
            require "win32ole"
          rescue LoadError
          end
          @is_win ||= Object.const_defined?("WIN32OLE")
        end # }}}

        # Find the path to rackup, by searching for -R (undocumented cli argument),
        # then checking RUBYLIB for the _first_ rack it can find there, finally
        # falling back to gems and looking for rackup in the gem bindir.
        # If we can't find rackup we're raising; not even #usage is sane without
        # rackup.
        def rackup_path # {{{
          return @rackup_path if @rackup_path
          # Use the supplied path if the user supplied -R
          if path_supplied = ARGV.delete("-R")
            @rackup_path = ARGV.delete(@ourargs[@ourargs.index("-R") + 1])
            if @rackup_path and File.file?(@rackup_path)
              return @rackup_path
            else
              $stderr.puts "rackup does not exist at #{@rackup_path} (given with -R)"
            end
          end
          # Check with 'which' on platforms which support it
          unless is_windows?
            @rackup_path = %x{which rackup}.to_s.chomp
            if @rackup_path.size > 0 and File.file?(@rackup_path)
              return @rackup_path
            end
          end
          # check for rackup in RUBYLIB
          libs = ENV["RUBYLIB"].to_s.split(is_windows? ? ";" : ":")
          if rack_lib = libs.detect { |r| r.match %r<(\\|/)rack\1> }
            require "pathname"
            @rackup_path = Pathname.new(rack_lib).parent.join("bin").join("rackup").expand_path
            return @rackup_path if File.file?(@rackup_path)
          end
          begin
            require "rubygems"
            require "rack"
            require "pathname"
            @rackup_path = Pathname.new(Gem.bindir).join("rackup").to_s
            return @rackup_path if File.file?(@rackup_path)
          rescue LoadError
            nil
          end
          @rackup_path = nil
          raise "Cannot find path to rackup, please supply full path to rackup with -R"
        end # }}}

        def is_running?(pid) # {{{
          if is_windows?
            wmi = WIN32OLE.connect("winmgmts://")
            processes, ours = wmi.ExecQuery("select * from win32_process where ProcessId = #{pid}"), []
            processes.each { |process| ours << process.Name }
            ours.first.nil?
          else
            begin
              prio = Process.getpriority(Process::PRIO_PROCESS, pid)
              true
            rescue Errno::ESRCH
              false
            end
          end
        end # }}}

        def check_running?(pid_file) # {{{
          return false unless File.file?(pid_file)
          is_running?(File.read(pid_file).to_i)
        end # }}}

        def find_pid(pid_file) # {{{
          if pid_file.nil? or not File.file?(pid_file)
            pid_file = default_pidfile
          end
          unless File.file?(pid_file)
            $stderr.puts "Could not find running process id."
            return false
          end
          pid_file
        end # }}}
      end # End helper methods }}}

      class Cmd # This class contains the command methods {{{
        include Helpers
        attr_accessor :command

        def initialize(args = nil)
          args ||= ARGV
          raise "arguments must be an array!" unless args.respond_to?(:detect)
          @ourargs = args.dup
          @command = args.detect { |arg| arg.match(/^(?:--?)?(?:start|stop|restart|create|h(?:elp)?|v(?:ersion)?|console|status)/) }
          if command.nil?
            @command = ""
          else
            args.delete(@command)
          end
          ARGV.replace(args)
        end

        # {{{ #run is called when we're interactive ($0 == __FILE__)
        def self.run(args = nil)
          cmd = new(args)
          case cmd.command
          when /^(?:--?)?status$/
            cmd.status(cmd.command)
          when /^(?:--?)?restart$/
            cmd.stop(cmd.command)
            cmd.start
          when /^(?:--?)?start$/
            cmd.start
          when /^(?:--?)?create$/
            cmd.create(cmd.command)
          when /^(?:--?)?stop$/
            if cmd.stop(cmd.command)
              puts "Ramazement has ended, go in peace."
              $stdout.flush
            else
              puts "Ramaze failed to stop (or was not running)"
            end
          when /^(?:--?)?console$/
            require "ramaze"
            require "irb"
            require "irb/completion"
            Ramaze.options.started = true
            require "start"
            IRB.start
            puts "Ramazement has ended, go in peace."
          when /^(?:--?)?h(elp)?$/
            puts cmd.usage
          when /^(?:--?)?v(ersion)?$/
            cmd.include_ramaze
            puts Ramaze::VERSION
            exit
          when /^$/
            puts "Must supply a valid command"
            puts cmd.usage
            exit 1
          else
            puts "#{command} not implemented"
            puts cmd.usage
            exit 1
          end
        end # }}}

        def include_ramaze # {{{
          begin
            $:.unshift File.join(File.dirname(__FILE__), '/../lib')
            require 'ramaze'
          rescue LoadError
            $:.shift

            begin
              require 'rubygems'
            rescue LoadError
            end
            require 'ramaze'
          end
        end # }}}

        def usage # {{{
          txt = [
            "\n  Usage:",
            "ramaze <start [PIDFILE]|stop [PIDFILE]|restart [PIDFILE]|status [PIDFILE]|create PROJECT|console> [ruby/rack options]\n",
            "Commands:\n",
            "  * All commands which take an optional PIDFILE (defaults to PROJECT.pid otherwise).",
            "  * All commands which start a ramaze instance will default to webrick on port 7000",
            "    unless you supply the rack options -p/--port PORT and/or * -s/--server SERVER.\n",
            " start   - Starts an instance of this application.\n",
            " stop    - Stops a running instance of this application.\n",
            " restart - Stops running instance of this application, then starts it back up.  Pidfile",
            "           (if supplied) is used for both stop and start.\n",
            " status  - Gives status of a running ramaze instance\n",
            " create  - Creates a new prototype Ramaze application in a directory named PROJECT in",
            "           the current directory.  ramaze create foo would make ./foo containing an",
            "           application prototype. Rack options are ignored here.\n",
            " console - Starts an irb console with app.rb (and irb completion) loaded. This command",
            "           ignores rack options, ARGV is passed on to IRB.\n\n\t"
          ].join("\n\t")

          if is_windows?
            txt << %x{ruby #{rackup_path} --help}.split("\n").reject { |line| line.match(/^Usage:/) }.join("\n\t")
          else
            txt << %x{#{rackup_path} --help}.split("\n").reject { |line| line.match(/^Usage:/) }.join("\n\t")
          end

          txt.gsub(/^\t$/, '')
        end # }}}

        ### Methods for commands {{{
        def start # {{{
          include_ramaze

          # Find the name of this app
          app_name = default_pidfile.sub(/\.pid$/,'')
          rack_args = []

          if daemonize = @ourargs.detect { |arg| arg.match(/^(-[dD]|--daemonize)$/) }
            if pid_arg = @ourargs.detect { |arg| arg.match(/^(-P|--pid)/) }
              puts "User supplied pid: #{pid_arg}"
              pid_file = @ourargs[@ourargs.index(pid_arg) + 1]
              puts "Starting daemon with user defined pidfile: #{pid_file}"
            else
              puts "Starting daemon with default pidfile: #{pid_file = default_pidfile}"
              rack_args += ["-P", pid_file]
            end
            if check_running?(pid_file)
              $stderr.puts "Ramaze is already running with pidfile: #{pid_file}"
              exit 127
            end
          end

          port = Ramaze.options.adapter.port.to_s
          rack_args += ["-p", port   ] if @ourargs.grep(/^(-p|--port)/).empty?

          handler = Ramaze.options.adapter.handler.to_s
          rack_args += ["-s", handler] if @ourargs.grep(/^(-s|--server)/).empty?

          if is_windows?
            exec("ruby", rackup_path.to_s, "config.ru", *(ARGV + rack_args))
          else
            exec(rackup_path.to_s, "config.ru", *(ARGV + rack_args))
          end
        end # }}}

        def create(command) # {{{
          opts = {}
          if forced = @ourargs.detect { |arg| arg.match(/^(--force)/) }
            puts "Overwriting any existing files as requested."
            opts[:force] = true
            @ourargs.delete(forced)
          end
          if amended = @ourargs.detect { |arg| arg.match(/^(--amend)/) }
            puts "Only amending missing files as requested."
            opts[:amend] = true
            @ourargs.delete(amended)
          end
          project_name = @ourargs[@ourargs.index(command) + 1]
          if project_name.nil?
            $stderr.puts "Must supply a project name" if project_name.nil?
            puts usage
            exit 1
          end
          include_ramaze
          require 'ramaze/tool/create'
          Ramaze::Tool::Create.create(project_name, opts)
        end # }}}

        def stop(command) # {{{
          unless pid_file = find_pid(@ourargs[@ourargs.index(command) + 1])
            $stderr.puts "No pid_file found!  Cannot stop ramaze (may not be started)."
            return false
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
        end # }}}

        def status(command) # {{{
          unless pid_file = find_pid(@ourargs[@ourargs.index(command) + 1])
            $stderr.puts "No pid_file found! Ramaze may not be started."
            exit 1
          end
          puts "Pid file #{pid_file} found, PID is #{pid = File.read(pid_file)}"
          unless is_running?(pid.to_i)
            $stderr.puts "PID #{pid} is not running"
            exit 1
          end
          if is_windows?
            wmi = WIN32OLE.connect("winmgmts://")
            processes, ours = wmi.ExecQuery("select * from win32_process where ProcessId = #{pid}"), []
            processes.each { |p| ours << [p.Name, p.CommandLine, p.VirtualSize, p.CreationDate, p.ExecutablePath, p.Status ] }
            puts "Ramaze is running!\n\tName: %s\n\tCommand Line: %s\n\tVirtual Size: %s\n\tStarted: %s\n\tExec Path: %s\n\tStatus: %s" % ours.first
          else
            require "pathname"
            # Check for /proc
            if File.directory?(proc_dir = Pathname.new("/proc"))
              proc_dir = proc_dir.join(pid)
              # If we have a "stat" file, we'll assume linux and get as much info
              # as we can
              if File.file?(stat_file = proc_dir.join("stat"))
                stats = File.read(stat_file).split
                puts "Ramaze is running!\n\tCommand Line: %s\n\tVirtual Size: %s\n\tStarted: %s\n\tExec Path: %s\n\tStatus: %s" % [
                  File.read(proc_dir.join("cmdline")).split("\000").join(" "),
                  "%s k" % (stats[22].to_f / 1024),
                  File.mtime(proc_dir),
                  File.readlink(proc_dir.join("exe")),
                  stats[2]
                ]
                exit
              end
            end
            # Fallthrough status, just print a ps
            puts "Ramaze process #{pid} is running!"
            begin
              puts %x{ps l #{pid}}
            rescue
              puts "No further information available"
            end
          end
        end # }}}

        ### End of command methods }}}
      end # }}}
    end
  end
end

if $0 == __FILE__
  Ramaze::Tool::Bin::Cmd.run(ARGV)
end
