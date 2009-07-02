task :gem_setup do
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

    def setup_gemspec(gemspec)
      gemspec.dependencies.each do |dependency|
        dependency.version_requirements.as_list.each do |version|
          gem(dependency.name, version)
        end
      end

      setup
    end

    # First try to activate.
    # If activation fails, try to install and activate again.
    # If the second activation also fails, try to require as it may just as
    # well be in $LOAD_PATH.
    def setup_gem(name, options)
      version = [options[:version]].compact
      lib_name = options[:lib] || name

      log "activating #{name}"

      Gem.activate(name, *version)
    rescue Gem::LoadError
      log "activating #{name} failed, try to install"

      install_gem(name, options)
    end

    # tell rubygems to install a gem
    def install_gem(name, options)
      installer = Gem::DependencyInstaller.new(options)

      temp_argv(options[:extconf]) do
        log "installing #{name}"
        installer.install(name, options[:version])
      end

      Gem.activate(name, *version)

      log "install and final activation successful"
    rescue Gem::GemNotFoundException => ex
      log "installation failed: #{ex}, use normal require"

      require(options[:lib] || name)

      log "require successful, cannot verify version though"
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
