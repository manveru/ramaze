#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FeedHelper

    # just a stub, for the moment, doing nothing more than calling
    # #to_xml on the object you pass

    def feed object
      object.to_xml
    end
  end
end

module ReFeed

  # Does a couple of things on include.
  #
  # defines #xml_accessor, which in turn offers a way to define
  # both an attr_accessor and xml-annotation.
  #   xml_accessor :name, :age
  #
  # defines #xml, a little DSLy way to add an attribute that
  # is later used to generate/read XML
  #   xml :name, :age
  #
  # defines #from_xml, which takes XML and maps the structure of the
  # XML to your instances accessors.
  #   Foo.new.from_xml('<name>manveru</name><age>22</age>')
  #   # #<Foo @name='manveru', @age=22>

  def self.included(klass)
    klass.class_eval do
      const_set('XML_ATTRIBUTES', {})

      class << self

        # Offers a way to define
        # both an attr_accessor and xml-annotation.
        #   xml_accessor :name, :age

        def xml_accessor(*args)
          args = xml(*args)
          attr_accessor(*args)
        end

        # A little DSLy way to add an attribute that
        # is later used to generate/read XML
        #   xml :name, :age

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

        # Which takes XML and maps the structure of the
        # XML to your instances accessors.
        #   Foo.new.from_xml('<name>manveru</name><age>22</age>')
        #   # #<Foo @name='manveru', @age=22>

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

  # return the XML_ATTRIBUTES of self.class

  def xml_attributes
    self.class::XML_ATTRIBUTES
  end

  # convert this instance to XML

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
      "<#{name} #{attributes.join(' ')}>#{xml}</#{name}>"
    end
  end
end
