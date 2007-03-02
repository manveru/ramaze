#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'amrita2/template'

module Ramaze::Template

  # Is responsible for compiling a template using the Amrita2 templating engine.

  class Amrita2 < Template

    Ramaze::Controller.register_engine self, %w[ amrita ]

    class << self

      # Takes a controller and the options :action, :parameter, :file and :binding
      # The file is rendered using Amrita2::TemplateFile.
      # The Controller is used as the object for expansion.
      #
      # The parameters are set to @params in the controller before expansion.

      def transform controller, options = {}
        action, parameter, file, bound = *super

        raise Ramaze::Error::Template, "No Template found for #{Request.current.request_path}" unless file

        template = ::Amrita2::TemplateFile.new(file)
        out = ''
        controller.instance_variable_set('@params', parameter)
        template.expand(out, controller)
        out
      end
    end
  end
end
