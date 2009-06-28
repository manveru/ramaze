require 'optparse'
require 'pathname'
require File.expand_path('../version', __FILE__) unless defined?(Ramaze::Version)

module Ramaze
  class Bin
    def self.lazy(trigger, &block)
      eval("def block.#{trigger}; call; end")
      block
    end

    attr_reader :args, :op, :options, :command

    env_paths = ENV['RAMAZE_PATH'].to_s.split(':')
    PATH = (env_paths + [File.expand_path('../bin', __FILE__)]).map{|path|
      Pathname(path)
    }

    def initialize(args)
      @args = args.dup
      @op = OptionParser.new(lazy_program_name, 24, '  ')
      @options = {}
    end

    def lazy_program_name
      Bin.lazy :to_s do
        ['ramaze', @command, '[options]'].compact.join(' ')
      end
    end

    def run
      global_parser

      load_command args.first do |cmd|
        @command = args.shift
        cmd.call
      end

      fallback
    end

    def global_parser
      op.program_name = 'ramaze'
      op.version = Ramaze::VERSION
      op.release = 'c) Michael Fellinger (manveru@rubyists.com'

      op.separator ''
      op.separator 'General options:'
      op.on("-e", "--eval LINE", "evaluate a LINE of code") { |line|
        eval line, TOPLEVEL_BINDING, "-e", lineno
        lineno += 1
      }
      op.on("-I", "--include PATH",
            "specify $LOAD_PATH (may be used more than once)"){|path|
        $LOAD_PATH.unshift(*path.split(":"))
      }
      op.on("-m", "--mode MODE", "Use given MODE (default dev)"){|mode|
        options[:mode] = mode.to_sym
      }
      op.on("-d", "--debug", "set $DEBUG to true"){ $DEBUG = true }
      op.on("-w", "--warn", "turn verbose warnings on"){ $-w = true }
      op.on('-R', '--rackup', 'path to the rackup executable'){|v|
        options[:rackup] = Pathname(v).expand_path
      }
      op.on('-h', '--help', 'Show command help'){ puts op; exit }
      op.on('-v', '--version', 'Show the version'){ puts op.ver; exit }
    end

    def load_command(name)
      name = Pathname(name.to_s).basename('.*').to_s

      command_files.find do |file|
        base = file.basename('.rb').to_s
        next unless base == name
        require file
        cmd = self.class.const_get(base.capitalize).new(self)
        return block_given? ? yield(cmd) : cmd
      end
    rescue LoadError
    end

    def command_files
      PATH.map{|dir|
        Pathname.glob(dir.join('*.rb').expand_path.to_s)
      }.flatten
    end

    def fallback
      op.parse! args
      puts op
      exit 1
    end

    module Helper
      # Try to require ramaze by all means possible.
      # First we try to find the ramaze that this tool/bin.rb file is in,
      # then we try relying on $LOAD_PATH, and if all fails we finally ask
      # rubygems for help.
      def require_ramaze
        require File.expand_path('../../ramaze', __FILE__)
      rescue LoadError
        require 'ramaze'
      rescue LoadError
        require 'rubygems'
        require 'ramaze'
      end

      def default_pidfile
        return @default_pidfile if @default_pidfile
        pwd = Pathname('.').expand_path.basename
        @default_pidfile = Pathname("#{pwd}.pid")
      end

      # We're really only concerned about win32ole, so we focus our check on our
      # ability to load that
      def is_windows?
        return @is_windows unless @is_windows.nil?

        require 'win32ole'
        @is_win = Object.const_defined?(:WIN32OLE)

      rescue LoadError
        @is_win = Object.const_defined?(:WIN32OLE)
      end

      # Find the path to rackup, by searching for -R (undocumented cli argument),
      # then checking RUBYLIB for the _first_ rack it can find there, finally
      # falling back to gems and looking for rackup in the gem bindir.
      # If we can't find rackup we're raising; not even #usage is sane without
      # rackup.
      def rackup_path
        return @rackup_path if @rackup_path

        @rackup_path =
          rackup_path_from_argv ||
          rackup_path_from_which ||
          rackup_path_from_rubylib ||
          rackup_path_from_rubygems

        if @rackup_path
          @rackup_path
        else
          raise "Cannot find path to rackup, please supply full path with -R"
        end
      end

      # Use the supplied path if the user supplied -R
      def rackup_path_from_argv
        if path = @bin.options[:rackup]
          return path if path.file?
          warn "rackup does not exist at #{path} (given with -R)"
        end
      end

      # Check with 'which' on platforms that support it
      def rackup_path_from_which
        return if is_windows?
        require 'open3'

        path = Open3.popen3('which', 'rackup'){|si,so,se| so.read.chomp }
        path if path.size > 0 && File.file?(path)
      rescue Errno::ENOENT
        # which couldn't be found or something nasty happened
      end

      # check for rackup in RUBYLIB
      def rackup_path_from_rubylib
        env_path_separator = is_windows? ? ';' : ':'
        path_separator = Regexp.escape(File::ALT_SEPARATOR || File::SEPARATOR)
        needle = /#{path_separator}rack#{path_separator}/

          paths = ENV["RUBYLIB"].to_s.split(env_path_separator)

        if rack_lib = paths.find{|path| path =~ needle }
          path = Pathname.new(rack_lib).parent.join("bin").join("rackup").expand_path
          path if path.file?
        end
      end

      def rackup_path_from_rubygems
        require 'rubygems'
        require 'rack'
        path = Pathname.new(Gem.bindir).join('rackup')
        path if path.file?
      rescue LoadError
      end

      def is_running?(pid)
        is_windows? ? runs_under_windows?(pid) : runs_under_posix?(pid)
      end

      def runs_under_windows?(pid)
        wmi = WIN32OLE.connect("winmgmts://")
        processes = wmi.ExecQuery("select * from win32_process where ProcessId = #{pid}")
        processes.map{|process| process.Name }.first.nil?
      end

      def runs_under_posix?(pid)
        Process.getpriority(Process::PRIO_PROCESS, pid)
        true
      rescue Errno::ESRCH
        false
      end

      # Make sure a process is running with the pid found in the +pid_file+
      def check_running?(pid_file)
        return false unless File.file?(pid_file)
        is_running?(pid_in(pid_file))
      end

      def pid_in(pid_file)
        File.read(pid_file).to_i
      end

      def find_pid(pid_file)
        if pid_file && File.file?(pid_file)
          pid_file
        elsif File.file?(default_pidfile)
          default_pidfile
        else
          warn "Couldn't find running process id."
        end
      end
    end # Helper

    class Generic
      include Helper

      def initialize(bin)
        @bin = bin
        @default_pidfile = @is_windows = @rackup_path = nil
      end

      def description
        self.class::DESC
      end

      def help
        self.class::HELP
      end

      def parser(o, options)
      end

      def run(options)
      end

      def call(args = @bin.args, options = @bin.options)
        @bin.op.new
        parser(@bin.op, options)
        @bin.op.top.prepend 'Command options:', nil, nil
        @bin.op.top.prepend '', nil, nil
        @bin.op.parse!(args)
        run(@bin.options)
      end
    end
  end
end
