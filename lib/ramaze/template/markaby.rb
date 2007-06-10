#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'markaby'

module Ramaze
  module Template
    class Markaby < Template
      ENGINES[self] = %w[ mab ]

      class << self

        # initializes the handling of a request on the controller.
        # Creates a new instances of itself and sends the action and params.
        # Also tries to render the template.
        # In Theory you can use this standalone, this has not been tested though.

        def transform action
          result, file = result_and_file(action)

          result = transform_file(file, action) if file
          result.to_s
        end

        def transform_file file, action
          instance = action.instance
          ivs = extract_ivs(instance)

          instance.send(:mab, ivs) do
            instance_eval(file)
          end
        end

        def extract_ivs(controller)
          controller.instance_variables.inject({}) do |hash, iv|
            sym = iv.gsub('@', '').to_sym
            hash.merge! sym => controller.instance_variable_get(iv)
          end
        end
      end
    end
  end
end
