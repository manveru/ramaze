module Ramaze
  class Bin
    class Help < Generic
      DESC = 'Show short description and usage for given command'
      HELP = <<-DOC
SYNOPSIS
  ramaze help COMMAND

DESCRIPTION
  Show command synopsis, short description, and usage information for the given command.

USAGE
  ramaze help create
  ramaze help start -u
  ramaze help stop -d
      DOC

      def parser(o, options)
        o.on('-u', '--usage', 'Show only usage'){ options[:usage] = true }
        o.on('-d', '--description', 'Show only description'){ options[:desc] = true }
      end

      def run(options)
        command = @bin.args.shift

        @bin.load_command command do |cmd|
          show(cmd, options)
          exit
        end

        warn 'You must specify a command that you want to display help for.'
        warn 'Available commands are:'
        puts
        list_commands
        puts

        exit 1
      end

      private

      def list_commands
        @bin.command_files.each do |file|
          show_from_name(file.basename('.rb'))
        end
      end

      def show_from_name(name)
        @bin.load_command name do |cmd|
          print "ramaze #{name}\t"
          show(cmd, :desc => true)
        end
      end

      def show(command, options)
        if options[:usage]
          puts command.help
        elsif options[:desc]
          puts command.description
        else
          puts command.description
          puts
          puts command.help
        end
      end
    end
  end
end
