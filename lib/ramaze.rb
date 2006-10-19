$:.unshift File.dirname(File.expand_path(__FILE__))

require 'ostruct'
require 'pp'

# The main namespace for Ramaze

module Ramaze
  %w[
    Error Logger Global Template Controller Gestalt
    Request Response Dispatcher Session
  ].each{ |const| autoload(const, "ramaze/#{const.downcase}") }

  include Logger

  def start options = {}
    info "Starting up Ramaze (Version #{VERSION})"

    require 'ramaze/snippets'

    Thread.abort_on_exception = true

    setup_global(options)
    find_controllers
    setup_controllers

    autoreload 1

    info :global, Global

    trap(Global.shutdown_trap){ shutdown } rescue nil

    init_adapter
  end

  alias run start

  # A simple and clean way to shutdown Ramaze, use this

  def shutdown
    info "Shutting down Ramaze"
    Global.running_adapter.kill if Global.running_adapter
    exit
  end

  # Setup the variables for Global
  # This method can take a hash that maybe be used to override the defaults
  # That functionality is not used at the moment anywhere in ramaze.
  # Example:
  #   Ramaze.setup_global :adapter => :mongrel, :mode => :live, :port => 80
  #
  # The default values:
  #   uses the class from Adapter:: (is required automatically)
  #       Global.adapter #=> :mongrel
  #   restrict access to a specific host
  #       Global.host #=> '0.0.0.0'
  #   adapter runs on that port
  #       Global.port #=> 7000
  #   the running/debugging-mode (:debug|:stage|:live) - atm only differ in verbosity
  #       Global.mode #=> :debug
  #   detaches Ramaze to run in the background (used for testcases)
  #       Global.run_loose #=> false
  #   caches requests to the controller based on request-values (action/params)
  #       Global.cache #=> false
  #   run tidy over the generated html if Content-Type is text/html
  #       Global.tidy #=> false
  #   display an error-page with backtrace on errors (empty page otherwise)
  #       Global.error_page    #=> true
  #   trap this signal for clean shutdown (calls Ramaze.shutdown)
  #       Global.shutdown_trap #=> 'SIGINT'  

  def setup_global options = {}
    defaults = {
      :adapter      => :mongrel,
      :host         => '0.0.0.0',
      :port         => 7000,
      :mode         => :debug,
      :run_loose    => false,
      :cache        => false,
      :tidy         => false,
      :error_page   => true,
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
    # TODO: implement some intelligent hooking like:
    #       '/foo' => FooController
    #       (remark: maybe use Main|Base|Index and the like if we have them)
    Global.controllers.map! do |controller|
      controller = constant(controller)
      controller.send(:include, Ramaze::Controller)
    end
  end

  def init_adapter
    if Global.run_loose
      Thread.new do
        Global.running_adapter = run_adapter
      end
    else
      Global.running_adapter = run_adapter.join
    end
  end

  def run_adapter
    adapter, host, port = Global.values_at(:adapter, :host, :port)
    require "ramaze/adapter" / adapter.to_s.downcase
    adapter_klass = Ramaze::Adapter.const_get(adapter.to_s.capitalize)

    info "Found adapter: #{adapter_klass}"
    info "we're running: #{host}:#{port}"

    adapter_klass.start host, port
  rescue => ex
    puts ex
    join = Thread.list.reject{|t| t == Thread.current or t.dead?}
    puts "joining #{join.size} threads and retry"
    join.each{|t| t.join }
    retry
  end

  extend self
end
