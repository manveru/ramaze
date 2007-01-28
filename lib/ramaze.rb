#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))
end

$:.unshift Ramaze::BASEDIR

require 'socket'
require 'timeout'
require 'ostruct'
require 'set'
require 'pp'

require 'ramaze/snippets'
require 'ramaze/cache'
require 'ramaze/controller'
require 'ramaze/dispatcher'
require 'ramaze/error'
require 'ramaze/gestalt'
require 'ramaze/global'
require 'ramaze/inform'
require 'ramaze/http_status'
require 'ramaze/model'
require 'ramaze/snippets'
require 'ramaze/template'
require 'ramaze/version'

module Ramaze
  include Inform

  # This initializes all the other stuff, Controller, Adapter and Global
  # which in turn kickstart Ramaze into duty.
  # additionally it starts up the autoreload , which reloads all the stuff every
  # second in case it has changed.
  # please note that Ramaze will catch SIGINT (^C) and kill the running adapter
  # at that event, this provides a nice and clean way to shut down.
  #
  # The start might be a bit odd, but i think it is a quite decent hack, what
  # it does is following.
  # It looks up who called the start-method, and if the method that called it
  # is not the file that was run first, it will return without doing anything
  # The use of this is:
  # If you start ramaze over the CLI, using ruby main.rb
  # and the start-method is called in your main.rb, it will run, using the
  # configuration from you without any modifcation (just with the defaults)
  # In case you start it via the ramaze-command however, you may pass options
  # that could be overwritten by your application, but you just want to use
  # these options temporarily - in this case the start-call from your main.rb
  # will simply be ignored, the start from bin/ramaze is invoked which in turn
  # sets the options you passed on the commandline.
  # If you pertout want to run with bin/ramaze, pass commandline-options _and_
  # use the start-method your own application, use start(:force => true)
  # This also applies if your start is in another file than the file you
  # called first, therefor giving you the option to layout your application
  # as it pleases you.

  def start options = {}
    starter = caller[0].split(':').first
    return unless $0 == starter or options.delete(:force)

    init_global options

    info "Starting up Ramaze (Version #{VERSION})"

    Thread.abort_on_exception = true

    return if options.delete(:fake_start)

    find_controllers
    setup_controllers

    init_autoreload
    init_adapter
  end

  alias run start

  # same as start(:force => true)

  def force_start(options = {})
    start options.merge(:force => true)
  end

  alias force_run force_start

  def shutoff
    info "Killing the Threads"
    Global.adapter_klass.stop rescue nil
    (Thread.list - [Thread.main]).each do |thread|
      thread.kill
    end
  end

  alias exit shutoff

  # A simple and clean way to shutdown Ramaze

  def shutdown
    Timeout.timeout(2){ shutoff }
  rescue => ex
    puts ex
  ensure
    info "Shutdown Ramaze (it's save to kill me now if i hang)"

    if to = Global.inform[:to] and to.respond_to?(:close)
      debug "close #{to.inspect}"
      to.close until to.closed?
    end

    Kernel.exit
  end

  # first, search for all the classes that end with 'Controller'
  # like FooController, BarController and so on
  # then we search the classes within Ramaze::Controller as well

  def find_controllers
    Global.controllers ||= Set.new

    Module.constants.each do |klass|
      Global.controllers << constant(klass) if klass =~ /.+?Controller/
    end

    Ramaze::Controller.constants.each do |klass|
      klass = constant("Ramaze::Controller::#{klass}")
      Global.controllers << klass
    end

    debug "Found following Controllers: #{Global.controllers.inspect}"
  end

  # Setup the Controllers
  # This autogenerates a mapping and also includes Ramaze::Controller
  # in every found Controller.

  def setup_controllers
    Global.mapping ||= {}
    mapping = {}

    Global.controllers.each do |c|
      name = c.to_s.gsub('Controller', '').split('::').last
      if %w[Main Base Index].include?(name)
        mapping['/'] = c
      else
        mapping["/#{name.split('::').last.snake_case}"] = c
      end
      c.__send__(:send, :include, Ramaze::Controller)
    end

    Global.mapping.merge!(mapping) if Global.mapping.empty?
    # Now we make them to real Ramze::Controller s :)
    # also we set controller-variable as we go along, in case there
    # is only one controller it ends up hooked on '/'
    # otherwise we get some random one ...

    Global.controllers.map! do |controller|
      controller = constant(controller)
      controller.send(:include, Ramaze::Controller)
    end
  end

  def init_autoreload
    return unless Global.autoreload

    autoreload_interval = Global.autoreload[Global.mode]
    Ramaze::autoreload(autoreload_interval)
  end

  def init_global options = {}
    tmp_mapping = Global.mapping || {}

    if options.delete(:force_setup)
      Global.setup(options)
    else
      Global.update(options)
    end

    Global.mapping = tmp_mapping.merge(Global.mapping)
  end

  # Finally decide wether to use a main-thread to run Ramaze
  # so that further stuff can be done outside (very useful for testcases)
  # or we run it in standalone-mode, which is the default and waits
  # until the adapter is finished. (hopefully never ;)
  # change this behaviour by setting Global.run_loose = (true|false)
  # In every case the running adapter-thread is assigned to
  # Global.running_adapter

  def init_adapter
    (Thread.list - [Thread.current]).each do |thread|
      thread.kill if thread[:task] == :adapter
    end

    Thread.new do
      Thread.current.priority = 99
      Thread.current[:task] = :adapter
      Global.running_adapter = run_adapter

      trap(Global.shutdown_trap){ shutdown } rescue nil
    end

    Timeout.timeout(3) do
      sleep 0.1 until Global.running_adapter
    end
    Global.running_adapter.join unless Global.run_loose
  rescue Object => ex
    debug ex.message unless ex.is_a? Interrupt
    shutdown
  end

  # This first picks the right adapter according to Global.adapter
  # It also looks for Global.host and Global.port and passes it on
  # to the class-method of the adapter ::start

  def run_adapter
    adapter, host, port = Global.values_at(:adapter, :host, :port)
    require_adapter(adapter)

    adapter_klass = Ramaze::Adapter.const_get(adapter.to_s.capitalize)
    Global.adapter_klass = adapter_klass

    info "Found adapter: #{adapter_klass}, trying to connect to #{host}:#{port} ..."

    shutdown unless connection_possible(host, port)
    info "and we're running: #{host}:#{port}"

    adapter_klass.start host, port
  end

  def require_adapter adapter
    require "ramaze/adapter" / adapter.to_s.downcase
  rescue LoadError => ex
    puts ex
    puts "Please make sure you have an adapter called #{adapter}"
    shutdown
  end

  def connection_possible host, port
    Timeout.timeout(1) do
      TCPServer.open(host, port){ true }
    end
  rescue => ex
    puts ex.message
    false
  end
  extend self
end
