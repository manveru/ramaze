require 'ramaze'
require 'ramaze/gestalt'

module Ramaze
  module Helper
    # This helper tries to be an even better way to build forms
    # programmatically, see the specs for lots of examples.
    module BlueForm
      def form(options = {}, &block)
        form = Form.new(options)
        form.build(form_errors, &block)
        form
      end

      def form_error(name, message)
        if respond_to?(:flash)
          old = flash[:form_errors] || {}
          flash[:form_errors] = old.merge(name.to_s => message.to_s)
        else
          form_errors[name.to_s] = message.to_s
        end
      end

      def form_errors
        if respond_to?(:flash)
          flash[:form_errors] ||= {}
        else
          @form_errors ||= {}
        end
      end

      def form_errors_from_model(obj)
        obj.errors.each do |key, value|
          form_error(key.to_s, value.first % key)
        end
      end

      # Note that an instance of this class is not thread-safe, so you should
      # modify it only within one thread of execution
      class Form
        attr_reader :g

        def initialize(options)
          @form_args = options.dup
          @g = Gestalt.new
        end

        def build(form_errors = {})
          @form_errors = form_errors

          @g.form(@form_args) do
            if block_given?
              @g.fieldset do
                yield self
              end
            end
          end
        end

        def legend(text)
          @g.legend(text)
        end

        def input_text(label, name, value = nil, args = {})
          id = id_for(name)
          args = args.merge(:type => :text, :name => name, :class => 'text', :id => id)
          args[:value] = value unless value.nil?

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias text input_text

        def input_password(label, name)
          id = id_for(name)
          args = {:type => :password, :name => name, :class => 'text', :id => id}

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias password input_password

        def input_submit(value = nil)
          args = {:type => :submit, :class => 'button submit'}
          args[:value] = value unless value.nil?

          @g.p do
            @g.input(args)
          end
        end
        alias submit input_submit

        def input_checkbox(label, name, checked = false)
          id = id_for(name)
          args = {:type => :checkbox, :name => name, :class => 'checkbox', :id => id}
          args[:checked] = 'checked' if checked

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias checkbox input_checkbox

        def input_radio(label, name, values, options = {})
          has_checked, checked = options.key?(:checked), options[:checked]

          @g.p do
            values.each_with_index do |(value, o_name), index|
              o_name ||= value
              id = id_for("#{name}-#{index}")

              o_args = {:type => :radio, :value => value, :id => id, :name => name}
              o_args[:checked] = 'checked' if has_checked && value == checked

              if error = @form_errors.delete(name.to_s)
                @g.label(:for => id){
                  @g.span(:class => :error){ error }
                  @g.input(o_args)
                  @g.out << o_name
                }
              else
                @g.label(:for => id){
                  @g.input(o_args)
                  @g.out << o_name
                }
              end
            end
          end
        end
        alias radio input_radio

        def input_file(label, name)
          id = id_for(name)
          args = {:type => :file, :name => name, :class => 'file', :id => id}

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias file input_file

        def input_hidden(name, value = nil)
          args = {:type => :hidden, :name => name}
          args[:value] = value.to_s unless value.nil?

          @g.input(args)
        end
        alias hidden input_hidden

        def textarea(label, name, value = nil)
          id = id_for(name)
          args = {:name => name, :id => id}

          @g.p do
            label_for(id, label, name)
            @g.textarea(args){ value }
          end
        end

        def select(label, name, values, options = {})
          id = id_for(name)
          multiple, size = options.values_at(:multiple, :size)

          args = {:id => id}
          args[:multiple] = 'multiple' if multiple
          args[:size] = (size || multiple || 1).to_i
          args[:name] = multiple ? "#{name}[]" : name

          has_selected, selected = options.key?(:selected), options[:selected]

          @g.p do
            label_for(id, label, name)
            @g.select args do
              values.each do |value, o_name|
                o_name ||= value
                o_args = {:value => value}
                o_args[:selected] = 'selected' if has_selected && value == selected
                @g.option(o_args){ o_name }
              end
            end
          end
        end

        def to_s
          @g.to_s
        end

        private

        def label_for(id, value, name)
          if error = @form_errors.delete(name.to_s)
            @g.label("#{value} ", :for => id){ @g.span(:class => :error){ error } }
          else
            @g.label(value, :for => id)
          end
        end

        def id_for(field_name)
          if name = @form_args[:name]
            "#{name}-#{field_name}".downcase.gsub(/_/, '-')
          else
            "form-#{field_name}".downcase.gsub(/_/, '-')
          end
        end
      end
    end
  end
end
