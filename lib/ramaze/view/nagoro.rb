require 'nagoro'

module Innate
  module View
    module Nagoro
      def self.render(action, string = nil)
        string ||= action.view

        # action.options[:pipes] ||= []
        action.options[:filename] ||= action.view
        action.options[:binding] = action.binding
        action.options[:variables] = action.variables

        ::Nagoro.render(string.to_s, action.options)
      end
    end
  end
end
