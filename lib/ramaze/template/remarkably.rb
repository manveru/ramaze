#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'remarkably'

module Ramaze
  module Template
    class Remarkably < Template
      Controller.register_engine self, %w[ rem ]
      class << self
        def transform controller, options = {}
          action, parameter, file, bound = *super
          unless controller.private_methods.include?( action )
            response = controller.send( action, *parameter )
            result = if file
              controller.instance_eval do
                args = parameter
                instance_eval File::read( file )
              end
            else
              response
            end
            if result.kind_of? Controller
              result.remarkably
            else
              result
            end
          end
        end
      end
    end
  end
end
