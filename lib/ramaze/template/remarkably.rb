#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'remarkably/engines/html'

module Ramaze
  module Template
    class Remarkably < Template
      ENGINES[self] = %w[ rem ]

      class << self
        def transform action
          result, file = result_and_file(action)

          result = transform_file(file, action) if file
          result.to_s
        end

        def transform_file(file, action)
          action.instance.instance_eval do
            args = action.params
            instance_eval(file)
          end
        end
      end
    end
  end
end
