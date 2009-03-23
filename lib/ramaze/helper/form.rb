require 'ramaze/gestalt'

module Ramaze
  module Helper
    module Form
      def form_text(label, name, value = nil)
        form_input(label, :type => :text, :name => name, :value => value)
      end

      def form_checkbox(label, name, checked = false)
        hash = {:type => :checkbox, :name => name}
        hash[:checked] = 'checked' if checked
        form_input(label, hash)
      end

      def form_password(label, name)
        form_input(label, :type => :password, :name => name)
      end

      def form_textarea(label, name, value = nil)
        form_build(:textarea, label, :name => name){ value }
      end

      def form_file(label, name)
        form_input(label, :type => :file, :name => name)
      end

      def form_input(label, hash)
        form_build(:input, label, hash)
      end

      def form_build(tag_name, label, hash, &block)
        form_id = "form-#{hash[:name]}"
        opts = hash.merge(form_tabindex.merge(:id => form_id))
        errors = form_errors

        Ramaze::Gestalt.build do
          tr do
            td do
              label(:for => form_id){ "#{label}:" }
              if error = errors[opts[:name]]
                div(:class => "error"){ error }
              end
            end
            td do
              tag(tag_name, opts, &block)
            end
          end
        end
      end

      def form_tabindex
        @tabindex ||= 0
        @tabindex += 1

        {:tabindex => @tabindex}
      end

      def form_error(name, message)
        form_errors[name.to_s] = message.to_s
      end

      def form_errors
        @form_errors ||= {}
      end

      def form_errors_from_model(obj)
        obj.errors.each do |key, value|
          form_error(key, value.first % key)
        end
      end
    end
  end
end
