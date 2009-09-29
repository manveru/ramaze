require 'erector'

module Ramaze
  module View
    module Erector
      class ::Erector::Widget
        alias :raw! :rawtext

        def strict_xhtml(*args, &block)
          raw! '<?xml version="1.0" encoding="UTF-8"?>'
          raw! '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">'
          html(:xmlns => "http://www.w3.org/1999/xhtml", :"xml:lang" => "en", :lang => "en", &block)
        end

        def inspect(elem)
          text elem.inspect
        end
      end

      def self.call(action, string)
        return string, 'text/html' unless action.view

        html = ::Erector.inline do
          # copy instance variables into Erector context
          action.instance.instance_variables.each do |v|
            instance_variable_set(v, action.instance.instance_variable_get(v))
          end

          eval(string)
        end.to_s

        return html, 'text/html'
      end
    end
  end
end
