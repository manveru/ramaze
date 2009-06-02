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
        Ramaze::Gestalt.build{ input(:type => :hidden, :name => name, :value => value) }
      end

      def form_submit(value = nil)
        hash = {:type => :submit}.merge(form_tabindex)
        hash[:value] = value if value
        Ramaze::Gestalt.build{ tr{ td(:colspan => 2){ input(hash) }}}
      end

      # @example usage, normal select drop-down
      #
      #   form_select('Favourite colors', :colors, @colors, :selected => @color)
      #
      # @example usage for pre-selected value
      #
      #   form_select('Favourite colors', :colors, @colors, :selected => @color)
      #
      # @example usage, allow selecting multiple
      #
      #   form_select('Cups', :cups, @cups, :selected => @cup, :multiple => 5)
      def form_select(label, name, values, hash = {})
        name = name.to_sym
        id = "form-#{name}"
        multiple, size = hash.values_at(:multiple, :size)

        s_args = {:name => name, :id => id}.merge(form_tabindex)
        s_args[:multiple] = :multiple if multiple
        s_args[:size] = (size || multiple || 1).to_i

        has_selected, selected = hash.key?(:selected), hash[:selected]
        error = form_errors[name.to_s]

        g = Ramaze::Gestalt.new
        g.tr do
          g.td do
            g.label(:for => id){ "#{label}:" }
            g.span(:class => 'error'){ error } if error
          end
          g.td do
            g.select(s_args) do
              values.each do |key, value|
                value ||= key
                o_args = {:value => value}
                o_args[:selected] = :selected if has_selected and value == selected
                g.option(o_args){ key }
              end
            end
          end
        end

        g.to_s
      end

      def form_input(label, hash)
        form_build(:input, label, hash)
      end

      def form_build(tag_name, label, hash, &block)
        name = hash[:name].to_sym
        form_id = "form-#{name}"
        opts = hash.merge(form_tabindex.merge(:id => form_id))
        error = form_errors[name.to_s]

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
