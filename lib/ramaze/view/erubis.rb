#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze
  module View
    module Erubis
      OPTIONS = { :engine => ::Erubis::Eruby }

      def self.render(action, string = nil)
        options = OPTIONS.dup
        engine = options.delete(:engine)

        eruby = engine.new(string, options)
        eruby.init_evaluator(:filename => (action.view || __FILE__))
        eruby.result(action.binding)
      end
    end
  end
end
