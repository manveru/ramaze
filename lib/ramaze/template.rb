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

      class << self

        # pass it the results of the method of the controller
        # and a possible file, it will see if the file is an actual file
        # and otherwise answer the contents of the response from the controller
        # if it responds to :to_str.
        #
        # Answers nil if none of both is valid.

        def reaction_or_file action
          reaction = render_method(action)

          if file = action.template
            File.read(file)
          else
            reaction.to_s
          end
        end

        def result_and_file(action)
          result = render_method(action)

          if file = action.template
            content = File.read(file)
          end

          [result, content]
        end

        def render_method(action)
          return unless method = action.method
          action.controller.__send__(method, *action.params)
        end
      end
    end
  end
end
