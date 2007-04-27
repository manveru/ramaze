#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))
end

$:.unshift Ramaze::BASEDIR

require 'timeout'
require 'ostruct'
require 'socket'
require 'yaml'
require 'set'
require 'pp'

require 'ramaze/snippets'
require 'ramaze/cache'
require 'ramaze/trinity'
require 'ramaze/error'
require 'ramaze/inform'
require 'ramaze/global'
require 'ramaze/dispatcher'
require 'ramaze/gestalt'
require 'ramaze/http_status'
require 'ramaze/helper'
require 'ramaze/controller'
require 'ramaze/template/ezamar'
require 'ramaze/adapter'
require 'ramaze/version'

Thread.abort_on_exception = true

module Ramaze

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
    return unless ($0 == starter or options.delete(:force))

    init_global options

    return if options.delete(:fake_start)

    Inform.info("Starting up Ramaze (Version #{VERSION})")
    startup
  end

  alias run start

  # same as start(:force => true)

  def force_start(options = {})
    start options.merge(:force => true)
  end

  alias force_run force_start

  # Execute the tasks specified in Global.startup
  # (where you can define your own tasks)
  # and afterwards the ones in Global.ramaze_startup
  # (reserved for the usage of Ramaze itself)

  def startup
    tasks = Global.startup + Global.ramaze_startup
    execute(*tasks)
  end

  # Execute the tasks specified in Global.shutdown
  # (where you can define your own tasks)
  # and afterwards the ones in Global.ramaze_shutdown
  # (reserved for the usage of Ramaze itself)

  def shutdown
    tasks = Global.shutdown + Global.ramaze_shutdown
    execute(*tasks)
  end

  # executes a list of tasks, depending on the task-object, if it responds to
  # :call it will be called upon, otherwise the task is sent to self ( the
  # module Ramaze ).

  def execute *tasks
    tasks.flatten.each do |task|
      begin
        if task.respond_to?(:call)
          task.call
        else
          send(task)
        end
      rescue Object => ex
        exit if ex.is_a?(SystemExit)
        Inform.error(ex)
      end
    end
  end

  # kill all threads except Thread.main before #shutdown

  def kill_threads
    Inform.info("Killing the Threads")
    Global.adapter_klass.stop rescue nil
    (Thread.list - [Thread.main]).each do |thread|
      Timeout.timeout(2) do
        if thread[:adapter] and thread[:adapter].respond_to?(:shutdown)
          thread[:adapter].shutdown
        end
        thread.kill
      end
    end
  end

  # Setup the Controllers
  # This autogenerates a mapping and does some munging/validation on the way

  def setup_controllers
    Global.mapping ||= {}

    Global.mapping.dup.each do |route, controller|
      Global.mapping[route] = constant(controller.to_s)
    end

    Global.controllers.each do |controller|
      if map = controller.mapping
        Global.mapping[map] ||= controller
        Inform.debug("mapped #{map} => #{controller}")
      end
    end
  end

  # Initialize the Kernel#autoreload with the value of Global.autoreload

  def init_autoreload
    return unless Global.autoreload
    Ramaze.autoreload Global.autoreload
  end

  # initialize the Global, setting a default-mapping if none is given yet.
  #
  # You may pass :force_setup => true in your options if you want your options
  # to override everything else set till now.

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
    Inform.debug(ex.message) unless ex.is_a? Interrupt
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

    Inform.info("Found adapter: #{adapter_klass}, trying to connect to #{host}:#{port} ...")

    parse_port(port)
    shutdown unless test_connections(host, Global.ports)
    Inform.info("and we're running: #{host}:#{port}")

    adapter_klass.start host, Global.ports
  end

  # require the specified adapter from 'ramaze/adapter/name.to_s.downcase'

  def require_adapter adapter
    require "ramaze/adapter" / adapter.to_s.downcase
  rescue LoadError => ex
    Inform.error(ex)
    puts "Please make sure you have an adapter called #{adapter}"
    shutdown
  end

  # convert ports given as string (7000..7007) to an actual range.
  # sets Global.port to the first of the ports given
  # sets Global.ports to the range (if one port given just a range from
  # that to the same (7000..7000)

  def parse_port port
    from_port, to_port = port.to_s.split('..')
    if from_port and to_port
      Global.ports = (from_port.to_i..to_port.to_i)
    else
      Global.ports = (from_port.to_i..from_port.to_i)
    end
    Global.port = Global.ports.begin
  end

  # test if a connection can be made at the specified host/ports.

  def test_connections host, ports
    return true unless Global.test_connections
    ports.map{|port| connection_possible(host, port) }.all?
  end

  # check connectivity to a specific host/port

  def connection_possible host, port
    Timeout.timeout(1) do
      TCPServer.open(host, port){ true }
    end
  rescue => ex
    Inform.error(ex)
    false
  end
  extend self
end
