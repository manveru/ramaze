require 'haml/util'
require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.call(action, string)
        options = action.options

        if haml_options = action.instance.ancestral_trait[:haml_options]
          options = options.merge(haml_options)
        end
        action.sync_variables(action)
        action.options[:filename] = (action.view || '(haml)')

        haml = View.compile(string) do |s| 
          var_names = action.instance.instance_variables
          var_names.collect! {|v| v.gsub('@','')}
          ::Haml::Engine.new(s,options).render_proc(action.instance,*var_names) 
        end
        html = haml.call action.variables

        return html, 'text/html'
      end
    end
  end
end
