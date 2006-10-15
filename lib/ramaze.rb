$:.unshift File.dirname(File.expand_path(__FILE__))

require 'ostruct'
require 'pp'

module Ramaze
  %w[
    Error Logger Global Template Controller Gestalt
    Request Response Dispatcher Adapter Session
  ].each{ |const| autoload(const, "ramaze/#{const.downcase}") }

  include Logger

  def start options = {}
    info "Starting up Ramaze"

    require 'ramaze/snippets'

    Thread.abort_on_exception = true

    setup_global(options)
    find_controllers
    setup_controllers

    autoreload 1

    info :global, Global

    if Global.run_loose
      Thread.new do
        Global.running_adapter = init_adapter
      end
    else
      Global.running_adapter = init_adapter.join
    end
  end

  alias run start

  def setup_global options = {}
    defaults = {
      :adapter      => :mongrel,
      :host         => '0.0.0.0',
      :port         => 7000,
      :mode         => :debug,
      :run_loose    => false,
      :cache        => false,
    }

    defaults.merge(options).each do |key, value|
      Global[key] ||= value
    end
  end

  # first, search for all the classes that end with 'Controller'
  # like FooController, BarController and so on
  # then we use the classes within Ramaze::Controller
  def find_controllers
    Global.controllers ||= []
    controllers = []

    Module.constants.each do |klass|
      controllers << constant(klass) if klass =~ /.+?Controller/
    end

    Ramaze::Controller.constants.each do |klass|
      klass = constant("Ramaze::Controller::#{klass}")
      controllers << klass
    end

    Global.controllers << controllers
    Global.controllers.flatten!
    Global.controllers.uniq!

    info "Found following Controllers: #{Global.controllers.inspect}"
  end

  def setup_controllers
    controller = Global.controllers.find{|c|
    }
    mapping = {}
    Global.controllers.each do |c|
      name = c.to_s.gsub('Controller', '')
      if %w[Main Base Index].include?(name)
        mapping['/'] = c
      else
        mapping["/#{name.downcase}"] = c
      end
      c.__send__(:send, :include, Ramaze::Controller)
    end

    Global.mapping ||= mapping
    # Now we make them to real Ramze::Controller s :)
    # also we set controller-variable as we go along, in case there
    # is only one controller it ends up hooked on '/'
    # otherwise we get some random one ...
    # TODO: implement some intelligent hooking like:
    #       '/foo' => FooController
    #       (remark: maybe use Main|Base|Index and the like if we have them)
    Global.controllers.map! do |controller|
      controller = constant(controller)
      controller.send(:include, Ramaze::Controller)
    end
  end

  def init_adapter
    adapter, host, port = Global.values_at(:adapter, :host, :port)
    require "ramaze/adapter/#{adapter}".downcase
    adapter_klass = Ramaze::Adapter.const_get(adapter.to_s.capitalize)

    info "Found adapter: #{adapter_klass}"
    info "we're running: #{host}:#{port}"

    adapter_klass.start host, port
  end

  extend self
end
