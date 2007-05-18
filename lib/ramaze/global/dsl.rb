#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  CLIOption = Struct.new('CLIOption', :name, :default, :doc, :cli)
  OPTIONS     = {}
  CLI_OPTIONS = []

  module GlobalDSL
    class << self
      def option_dsl(&block)
        instance_eval(&block)
      end

      def o(doc, options = {})
        cli_given = options.has_key?(:cli)
        cli = options.delete(:cli)
        name, default = options.to_a.flatten

        if cli_given
          option = CLIOption.new(name, default, doc, cli)
          CLI_OPTIONS << option
        end

        OPTIONS.merge!(options)
      end
    end
  end
end
