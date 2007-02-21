#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# This module serves as a namespace for all templates, it will autoload
# Amrita2, Erubis, Ezamar, Haml, Liquid and Markaby if you refer to them.

module Ramaze

  module Template
    autoload('Element', 'ramaze/template/ezamar/element')
    autoload('Morpher', 'ramaze/template/ezamar/morpher')

    %w[ Amrita2 Erubis Ezamar Haml Liquid Markaby ].each do |const|
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

        def reaction_or_file reaction, file
          if file
            File.read(file)
          elsif reaction.respond_to? :to_str
            reaction
          end
        end

        def transform controller, options = {}
          options.values_at(:action, :parameter, :file, :binding)
        end
      end
    end
  end
end
