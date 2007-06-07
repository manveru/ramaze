#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# This module serves as a namespace for all templates, it will autoload
# Amrita2, Erubis, Haml, Liquid and Markaby if you refer to them.

module Ramaze
  module Template

    %w[ Amrita2 Erubis Haml Liquid Markaby Remarkably ].each do |const|
      autoload(const, "ramaze/template/#{const.downcase}")
    end

    # The superclass for all templates, doesn't do much more than including
    # Ramaze::Helper and defining #reaction_or_file

    class Template
      include Ramaze::Helper

      COMPILED = {}

      class << self

        # calls result_and_file with the given action and returns the first of
        # the result of the controller or content of the file.

        def reaction_or_file action
          result_and_file(action).reverse.compact.first
        end

        # Takes an Action and returns the result from sending the action.method
        # to the controller via render_method and reads the contents of the file
        # if given.

        def result_and_file(action)
          result = render_method(action)

          if file = action.template
            content = File.read(file)
          end

          [result, content]
        end

        # returns nil if no method is on the action, otherwise it will send the
        # action and optional parameters to the controller via __send__ and
        # return the unaltered result

        def render_method(action)
          return unless method = action.method
          action.controller.__send__(method, *action.params)
        end
      end
    end
  end
end
