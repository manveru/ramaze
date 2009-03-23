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

      def form_hidden(name, value = nil)
        Ramaze::Gestalt.build{
          input(:type => :hidden, :name => name, :value => value)
        }
      end

      def form_submit(value = nil)
        hash = {:type => :submit}.merge(form_tabindex)
        hash[:value] = value if value
        Ramaze::Gestalt.build{ tr{ td(:colspan => 2){ input(hash) }}}
      end

      def form_input(label, hash)
        form_build(:input, label, hash)
      end

      def form_build(tag_name, label, hash, &block)
        form_id = "form-#{hash[:name]}"
        opts = hash.merge(form_tabindex.merge(:id => form_id))
        error = form_errors[opts[:name]]

        Ramaze::Gestalt.build do
          tr do
            td do
              label(:for => form_id){ "#{label}:" }
              span(:class => "error"){ error } if error
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
