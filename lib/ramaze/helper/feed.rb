#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FeedHelper
    def feed
    end
  end
end

module ReFeed
  def self.included(klass)
    klass.class_eval do
      const_set('XML_ATTRIBUTES', {})

      class << self
        def xml_accessor(*args)
          args = xml(*args)
          attr_accessor(*args)
        end

        def xml(*arguments)
          args = []
          hash = nil
          klass = Object.const_get(self.to_s)

          arguments.each do |arg|
            if arg.respond_to?(:to_sym)
              args << arg.to_sym
            elsif arg.respond_to?(:to_hash)
              hash = arg
            end
          end

          args.each do |arg|
            klass::XML_ATTRIBUTES[arg] = hash
          end
        end

        def from_xml(text)
          instance = self.new

          require 'hpricot'

          xml = Hpricot(text.to_s)
          attributes = instance.xml_attributes

          attributes.each do |attribute, opts|
            value = xml.at(attribute)
            instance.send("#{attribute}=", value.inner_html) if value
          end
          instance
        rescue LoadError => ex
          error ex
        ensure
          instance
        end
      end
    end
  end

  def xml_attributes
    self.class::XML_ATTRIBUTES
  end

  def to_xml
    name = self.class.name
    xml = xml_attributes.map do |key, opts|
      value = send(key)

      next unless value
      next if (opts[:type] == :attribute rescue false)

      if opts and not opts.empty?
        case opts[:type]
        when nil, :text : "<#{key}>#{value}</#{key}>"
        when :cdata : "<#{key}><![CDATA[#{value}]]></#{key}>"
        when :collection : value.map{|v| v.to_xml }
        end
      elsif value.respond_to?(:to_xml)
        value.to_xml
      elsif value.respond_to?(:all?) and value.all?{|v| v.respond_to?(:to_xml) }
        value.map{|v| v.to_xml }
      end
    end

    attributes = xml_attributes.select{|k, o| o && o[:type] == :attribute}
    attributes.map!{|k, o| %{#{k}="#{send(k)}"} }

    unless attributes or attributes.empty?
      "<#{name}>#{xml}</#{name}>"
    else
      "<#{name} #{attributes.join(' ')}><#{xml}></#{name}>"
    end
  end
end
