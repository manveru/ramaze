module Ramaze
  # An application is a collection of controllers and options that have a
  # common name.
  # Every application has a location it dispatches from, this behaves similar
  # to Rack::URLMap.

  AppMap = Innate::URLMap.new

  def self.to(object)
    app_name = object.ancestral_trait[:app]
    App[app_name].to(object)
  end

  # App is the superclass for applications and acts as their prototype when it
  # comes to configuration.
  #
  # An application consists of options, a location, and a list of objects. The
  # objects are usually {Controller}s.
  #
  # The options are inherited, the basics are set in Ramaze.options, from there
  # to Ramaze::App.options, and finally into every instance of App.
  #
  # This allows to collect {Controller}s of your application into a common
  # group that can easily be used in other applications, while retaining the
  # original options.
  #
  # Every instance of {App} is mapped in {AppMap}, which is the default
  # location to #call from Rack.
  #
  # Additionally, every {App} can have custom locations for
  # root/public/view/layout directories, which allows reuse beyond directory
  # boundaries.
  #
  # In contrast to Innate, where all Nodes share the same middleware, {App}
  # also has a subset of middleware that handles serving static files, routes
  # and rewrites.
  #
  # To indicate that a {Controller} belongs to a specific application, you can
  # pass a second argument to {Controller::map}
  #
  # @example adding Controller to application
  #
  #   class WikiController < Ramaze::Controller
  #     map '/', :wiki
  #   end
  #
  # The App instance will be created for you and if you don't use any other
  # applications in your code there is nothing else you have to do. Others can
  # now come and simply reuse your code in their own applications.
  #
  # There is some risk of name collisions if everybody calls their app `:wiki`,
  # but given that you only use one foreign app of this kind might give less
  # reason for concern.
  #
  # If you still try to use two apps with the same name, you have to be
  # careful, loading one first, renaming it, then loading the second one.
  #
  # The naming of an App has no influence on any other aspects of dispatching
  # or configuration.
  class App
    include Innate::Optioned

    # options not found here will be looked up in Ramaze.options
    options.dsl do
      o "Unique identifier for this application",
        :name, :pristine
    end

    APP_LIST = {}

    attr_reader :name, :location, :url_map, :options

    def initialize(name, location = nil)
      @name = name.to_sym
      @url_map = Innate::URLMap.new
      self.location = location if location

      APP_LIST[@name] = self

      @options = self.class.options.sub(@name)
    end

    def sync
      AppMap.map(location, self)
    end

    def location=(location)
      @location = location.to_str.freeze
      sync
    end

    def call(env)
      to_app.call(env)
    end

    def to_app
      files = Ramaze::Files.new(*public_roots)
      app = Current.new(Route.new(url_map), Rewrite.new(url_map))
      Rack::Cascade.new([files, app])
    end

    def map(location, object)
      url_map.map(location, object)
    end

    def to(object)
      return unless mapped = url_map.to(object)
      [location, mapped].join('/').squeeze('/')
    end

    def public_roots
      roots, publics = [*options.roots], [*options.publics]
      roots.map{|root| publics.map{|public| ::File.join(root, public) }}.flatten
    end

    def self.find_or_create(name, location = nil)
      location = '/' if location.nil? && name == :pristine
      self[name] || new(name, location)
    end

    def self.[](name)
      APP_LIST[name.to_sym]
    end
  end
end
