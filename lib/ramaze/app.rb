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

  class App
    include Innate::Optional

    options.dsl do
      o "Unique identifier for this application",
        :name, name

      o "Root directories containing the application",
        :root, [File.dirname($0)]

      o "Root directories for view templates, relative to app root",
        :view, ['view']

      o "Root directories for layout templates, relative to app root",
        :layout, ['layout']

      o "Root directories for static public files, relative to app root",
        :public, ['public']

      o "Prefix of this application",
        :prefix, '/'

      trigger(:public){|v| Ramaze.middleware_recompile }
    end

    APP_LIST = {}

    attr_reader :name, :location, :map

    def initialize(name, location)
      @name = name.to_sym
      @map = Innate::URLMap.new
      self.location = location

      APP_LIST[@name] = self

      @options = self.class.options.sub(@name)
    end

    def options
      @options
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
      app = Current.new(Route.new(@map), Rewrite.new(@map))
      Rack::Cascade.new([files, app])
    end

    def map(location, object)
      @map.map(location, object)
    end

    def to(object)
      [location, @map.to(object)].join('/')
    end

    def public_roots
      roots, publics = [*options.root], [*options.public]
      roots.map{|root| publics.map{|public| ::File.join(root, public) }}.flatten
    end

    def self.find_or_create(name, location = '/')
      self[name] || new(name, location)
    end

    def self.[](name)
      APP_LIST[name.to_sym]
    end
  end
end
