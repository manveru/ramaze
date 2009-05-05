desc 'install all possible dependencies'
task :setup do
  GemInstaller.new do
    # core
    gem 'innate',     '= 2009.04'

    # misc
    gem 'bacon',      '>= 1.0'
    gem 'json',       '>= 1.1.3'
    gem 'memcache',   '~> 1.7.0'

    # templating engines
    gem 'Remarkably', '~> 0.5.2'
    gem 'erubis',     '>= 2.6.4'
    gem 'haml',       '~> 2.0.9'
    gem 'hpricot',    '>= 0.7'
    gem 'liquid',     '~> 2.0.0'
    gem 'sequel',     '>= 2.11.0'
    gem 'tagz',       '>= 5.0.1'
    gem 'tenjin',     '~> 0.6.1'

    setup
  end
end
