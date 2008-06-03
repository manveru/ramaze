module Ramaze
  module Gems
    @gems = []

    class << self
      def gem(name, version = nil, options = {})
        case version
        when String
          options[:version] = version
        when Hash
          options.merge!(version)
        end

        @gems << GemStone.new(name, options)
      end

      def options opts = {}
        @options ||= { :docs => true }
        @options.merge! opts unless opts.empty?
        @options
      end

      def setup opts = {}
        options(opts)
        @gems.each{|gem| gem.setup }
      end
    end

    class GemStone
      attr_reader :name, :options

      def initialize(name, options = {})
        @name, @options = name, options
      end

      def setup(ran = false)
        # rubygems resets the path after each successful install
        Gem.use_paths Gems.options[:install_dir] if Gems.options[:install_dir]

        Gem.activate(name, *[@options[:version]].compact)
        require options[:lib] || name
      rescue LoadError => error
        puts error
        return if ran
        puts "attempting install"
        install
        setup(ran = true)
      end

      def install
        require 'rubygems/gem_runner'
        version, source = options.values_at(:version, :source)

        cmd = %w[install] << name
        cmd << "--no-rdoc" << "--no-ri" unless Gems.options[:docs]
        cmd << "--install-dir" << Gems.options[:install_dir] if Gems.options[:install_dir]
        cmd << "--version" << version if version
        cmd << "--source" << source if source

        puts cmd * ' '
        Gem::GemRunner.new.run(cmd)
      rescue Gem::SystemExitException => e
        raise unless e.exit_code == 0
      end
    end
  end
end

__END__
Usage example:

module Ramaze::Gems
  gem 'haml'
  gem 'sequel', '>=1.2.0'
  gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  gem 'aws-s3', :lib => 'aws/s3'

  setup
end
