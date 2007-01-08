#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))
end

$:.unshift Ramaze::BASEDIR

# not very evil hack to make sure fastthread is required before
# anything else if it's available...
# hopefully some day rescue LoadError will work without begin..end

begin; require 'fastthread'; rescue LoadError; end


require 'timeout'
require 'ostruct'
require 'pp'

require 'ramaze/snippets'
require 'ramaze/controller'
require 'ramaze/dispatcher'
require 'ramaze/error'
require 'ramaze/gestalt'
require 'ramaze/global'
require 'ramaze/http_status'
require 'ramaze/inform'
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
  # at that event, this provides a nice and clean way to shut down. shutdown

  def start options = {}
    info "Starting up Ramaze (Version #{VERSION})"

    Thread.abort_on_exception = true

    Global.setup(options)

    find_controllers
    setup_controllers

    autoreload_interval = Global.autoreload[Global.mode]
    Ramaze::autoreload(autoreload_interval)

    init_adapter
  end

  alias run start

  def shutoff
    info "Power off Ramaze"
    Global.adapter_klass.stop
    (Thread.list - [Thread.main]).each do |thread|
      thread.kill
    end
  end

  # A simple and clean way to shutdown Ramaze

  def shutdown
    shutoff
    info "exit"
    exit
  end

  # first, search for all the classes that end with 'Controller'
  # like FooController, BarController and so on
  # then we search the classes within Ramaze::Controller as well

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

  # Setup the Controllers
  # This autogenerates a mapping and also includes Ramaze::Controller
  # in every found Controller.

  def setup_controllers
    mapping = {}

    Global.controllers.each do |c|
      name = c.to_s.gsub('Controller', '').split('::').last
      if %w[Main Base Index].include?(name)
        mapping['/'] = c
      else
        mapping["/#{name.downcase.split('::').last}"] = c
      end
      c.__send__(:send, :include, Ramaze::Controller)
    end

    Global.mapping ||= mapping
    # Now we make them to real Ramze::Controller s :)
    # also we set controller-variable as we go along, in case there
    # is only one controller it ends up hooked on '/'
    # otherwise we get some random one ...

    Global.controllers.map! do |controller|
      controller = constant(controller)
      controller.send(:include, Ramaze::Controller)
    end
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

    sleep 0.1 until Global.running_adapter
    Global.running_adapter.join unless Global.run_loose
  end

  # This first picks the right adapter according to Global.adapter
  # It also looks for Global.host and Global.port and passes it on
  # to the class-method of the adapter ::start
  # It rescues StandardException and does retry after joining all
  # still running threads (except for the current thread)

  def run_adapter
    adapter, host, port = Global.values_at(:adapter, :host, :port)
    begin
      require "ramaze/adapter" / adapter.to_s.downcase
    rescue LoadError => ex
      puts ex
      puts "Please make sure you have an adapter called #{adapter}"
      shutdown
    end
    adapter_klass = Ramaze::Adapter.const_get(adapter.to_s.capitalize)
    Global.adapter_klass = adapter_klass

    info "Found adapter: #{adapter_klass}"
    info "we're running: #{host}:#{port}"

    adapter_klass.start host, port
  rescue => ex
    timeouted ||= false
    join = Thread.list.reject{|t| t == Thread.current or t.dead? or t[:interval]}
    debug "joining #{join.size} threads and retry"
    begin
      Timeout.timeout(5) do
        join.each{|t| t.join }
      end
    rescue Timeout::Error => timeout
      if timeouted
        puts "sorry, please shutdown your other app first"
        shutdown
        exit
      end
      puts timeout
      puts "will still try to retry"
      timeouted = timeout
    end

    retry
  end
  extend self
end
