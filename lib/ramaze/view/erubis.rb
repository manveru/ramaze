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

        eruby = View.compile(string){|s| engine.new(s, options) }
        eruby.init_evaluator(:filename => (action.view || __FILE__))
        html = eruby.evaluate(action.instance)

        return html, 'text/html'
      end
    end
  end
end
