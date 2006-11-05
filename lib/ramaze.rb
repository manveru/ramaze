require 'ostruct'
require 'pp'

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))

  $:.unshift Ramaze::BASEDIR
  Dir[File.join(Ramaze::BASEDIR, 'ramaze/*.rb')].each{|file| require file }

  include Logger

  # This initializes all the other stuff, Controller, Adapter and Global
  # which in turn kickstart Ramaze into duty.
  # additionally it starts up the autoreload , which reloads all the stuff every
  # second in case it has changed.
  # please note that Ramaze will catch SIGINT (^C) and kill the running adapter
  # at that event, this provides a nice and clean way to shut down. shutdown

  def start options = {}
    info "Starting up Ramaze (Version #{VERSION})"

    require 'ramaze/snippets'

    Thread.abort_on_exception = true

    setup_global(options)
    find_controllers
    setup_controllers

    info :global, Global.pretty_inspect
    autoreload_interval = Global.autoreload[Global.mode]
    debug "initialize autoreload with #{autoreload_interval}"

    Ramaze::autoreload(autoreload_interval)

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
  #   the running/debugging-mode (:debug|:stage|:live|:silent) - atm only differ in verbosity
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
      :adapter        => :mongrel,
      :host           => '0.0.0.0',
      :port           => 7000,
      :mode           => :debug,
      :run_loose      => false,
      :cache          => false,
      :tidy           => false,
      :error_page     => true,
      :template_root  => 'template',

      :autoreload     => {
                          :benchmark  => 5,
                          :debug      => 5,
                          :stage      => 10,
                          :live       => 20,
                          :silent     => 40,
                         },
      :logger         => {
                          :timestamp    => "%Y-%m-%d %H:%M:%S",
                          :prefix_info  => 'INFO',
                          :prefix_error => 'ERRO',
                          :prefix_debug => 'DEBG',
                         }
    }

    defaults.merge(options).each do |key, value|
      Global[key] ||= value
    end
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
    if Global.run_loose
      Thread.new do
        Global.running_adapter = run_adapter
      end
      sleep 0.1 until Global.running_adapter
    else
      Global.running_adapter = run_adapter.join
    end
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
      exit
    end
    adapter_klass = Ramaze::Adapter.const_get(adapter.to_s.capitalize)

    info "Found adapter: #{adapter_klass}"
    info "we're running: #{host}:#{port}"

    adapter_klass.start host, port
  rescue => ex
    puts ex
    join = Thread.list.reject{|t| t == Thread.current or t.dead? or t[:interval]}
    puts "joining #{join.size} threads and retry"
    join.each{|t| t.join }
    retry
  end

  extend self
end
