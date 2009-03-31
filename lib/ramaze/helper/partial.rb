require 'innate/helper/partial'

module Ramaze
  module Helper
    module Partial
      include Innate::Helper::Partial

      def self.included(into)
        into.extend(self)
        into.extend(Innate::Helper::Partial)
      end

      def partial_content(name, variables = {})
        action = resolve(name.to_s)

        action.layout = nil

        action.instance = action.node.new
        action.variables = action.variables.merge(variables)

        action.render if action.valid?
      end
    end
  end
end
