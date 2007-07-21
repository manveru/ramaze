#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  CLIOption = Struct.new('CLIOption', :name, :default, :doc, :cli)
  OPTIONS     = {}
  CLI_OPTIONS = []

  # DSL for specifying Globap options before initializing Global

  module GlobalDSL
    class << self

      # The method that takes the block containing the DSL, used like in
      # lib/ramaze/global.rb

      def option_dsl(&block)
        instance_eval(&block)
      end

      # Takes a doc-string and then the option as hash, another :cli key can
      # be given that will expose this option via the bin/ramaze.

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
