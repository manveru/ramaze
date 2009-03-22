#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze
  module View
    module Erubis
      OPTIONS = { :engine => ::Erubis::Eruby }

      def self.call(action, string)
        options = OPTIONS.dup
        engine = options.delete(:engine)
        action.copy_variables

        eruby = engine.new(string, options)
        eruby.init_evaluator(:filename => (action.view || __FILE__))
        html = eruby.result(action.binding)

        return html, 'text/html'
      end
    end
  end
end
