#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  unless defined?(Action) # prevent problems for SourceReload

    # The Action holds information that is essential to render the action for a
    # request.

    members = %w[method params template controller binding engine instance]

    class Action < Struct.new('Action', *members)
    end
  end

  require 'ramaze/action/render'

  class Action
    class << self
      def fill(hash = {})
        i = new
        members.each do |key|
          i.send("#{key}=", (hash[key] || hash[key.to_sym]))
        end
        i
      end

      def current
        Thread.current[:action]
      end
    end

    def to_s
      %{#<Action method=#{method.inspect}, params=#{params.inspect} template=#{template.inspect}>}
    end

    def method=(meth)
      meth = meth.to_s
      self[:method] = (meth.empty? ? nil : meth)
    end

    # runs all parameters assinged through flatten and CGI.unescape

    def params=(*par)
      self[:params] = par.flatten.compact.map{|pa| CGI.unescape(pa.to_s)}
    end

    def relaxed_hash
      [controller, method, params, template].hash
    end

    def to_hash
      hash = {}
      members.each{|m| hash[m.to_sym] = send(m)}
      hash
    end

    # Determines based on trait :engine and the template extensions which
    # engine a template or Controller has to be processed with.

    def engine
      return self[:engine] if self[:engine]
      default = controller.trait.fetch(:engine, Template::Ezamar)
      return default unless template

      engines = Template::ENGINES
      return default if engines.empty?

      ext = File.extname(template).gsub(/^\./, '')
      ext_engine = engines.find{|e| e.last.include?(ext)}.first

      self[:engine] = (ext_engine || default)
    end

    def instance
      self[:instance] ||= controller.new
    end

    def binding
      self[:binding] ||= instance.instance_eval{ binding }
    end

    # Hook for AspectHelper

    def before_process
    end

    # Hook for AspectHelper

    def after_process
    end
  end

  def self.Action(hash = {})
    Action.fill(hash)
  end
end
