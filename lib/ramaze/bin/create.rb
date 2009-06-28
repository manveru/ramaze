module Ramaze
  class Bin
    class Create < Generic
      DESC = 'Make a new application without thinking too much'
      HELP = <<-DOC
SYNOPSIS
  ramaze create PROJECT [options]

DESCRIPTION
  Create a new prototype Ramaze application in a directory named PROJECT in the
  current directory. ramaze create foo would make ./foo containing an application
  prototype.

USAGE
  ramaze create blog
  ramaze create blog --amend
  ramaze create blog --force
  ramaze create blog --proto ~/.config/ramaze/proto --layout sequel
      DOC

      def parser(o, options)
        o.banner = 'ramaze create PROJECT [options]'

        o.on('-p', '--proto DIRECTORY', 'Directory containing proto layouts'){|v|
          options[:proto] = Pathname(v).expand_path
        }
        o.on('-l', '--layout NAME', 'Directory in proto containing proto files'){|v|
          options[:layout] = v
        }
        o.on('-a', '--amend', 'Only add missing files'){ options[:amend] = true }
        o.on('-f', '--force', 'Overwrite existing files'){ options[:force] = true }
      end

      def run(options)
        if project_name = @bin.args.shift
          create(project_name, options)
          exit
        else
          warn "You must supply a project name"
          exit 1
        end
      end

      private

      def create(name, options)
        require_ramaze
        require 'ramaze/tool/create'
        Ramaze::Tool::Create.create(name, options)
      end
    end
  end
end
