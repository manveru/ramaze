module Ramaze
  # Convenient setup and activation of gems from different sources and specific
  # versions.
  # It's almost like Kernel#gem but also installs automatically if a gem is
  # missing.
  #
  # @example
  #
  #   Ramaze.setup :verbose => true do
  #     # gem and specific version
  #     gem 'makura', '>=2009.01'
  #
  #     # gem and name for require
  #     gem 'aws-s3', :lib => 'aws/s3'
  #
  #     # gem with specific version from rubyforge (default)
  #     gem 'json', :version => '=1.1.3', :source => rubyforge
  #
  #     # gem from github
  #     gem 'manveru-org', :lib => 'org', :source => github
  #   end
  #
  # @option options [boolean] (true) verbose
  # @option options [String] (nil) extconf
  # @yield block
  # @see GemSetup#initialize
  # @author manveru
  def self.setup(options = {:verbose => true}, &block)
    GemSetup.new(options, &block)
  end

  class GemSetup
    def initialize(options = {}, &block)
      @gems = []
      @options = options.dup
      @verbose = @options.delete(:verbose)

      run(&block)
    end

    def run(&block)
      return unless block_given?
      instance_eval(&block)
      setup
    end

    def gem(name, version = nil, options = {})
      if version.respond_to?(:merge!)
        options = version
      else
        options[:version] = version
      end

      @gems << [name, options]
    end

    # all gems defined, let's try to load/install them
    def setup
      require 'rubygems'
      require 'rubygems/dependency_installer'

      @gems.each do |name, options|
        setup_gem(name, options)
      end
    end

    # first try to activate, install and try to activate again if activation
    # fails the first time
    def setup_gem(name, options)
      version = [options[:version]].compact
      lib_name = options[:lib] || name

      log "activating #{name}"

      Gem.activate(name, *version)
      require(lib_name)

    rescue LoadError

      install_gem(name, options)
      Gem.activate(name, *version)
      require(lib_name)
    end

    # tell rubygems to install a gem
    def install_gem(name, options)
      installer = Gem::DependencyInstaller.new(options)

      temp_argv(options[:extconf]) do
        log "Installing #{name}"
        installer.install(name, options[:version])
      end
    end

    # prepare ARGV for rubygems installer
    def temp_argv(extconf)
      if extconf ||= @options[:extconf]
        old_argv = ARGV.clone
        ARGV.replace(extconf.split(' '))
      end

      yield

    ensure
      ARGV.replace(old_argv) if extconf
    end

    private

    def log(msg)
      return unless @verbose

      if defined?(Log)
        Log.info(msg)
      else
        puts(msg)
      end
    end

    def rubyforge; 'http://gems.rubyforge.org/' end
    def github; 'http://gems.github.com/' end
  end
end
