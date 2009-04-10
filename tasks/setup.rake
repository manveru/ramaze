# Currently, Ramaze is not usable without Rack from the master branch head.
# Also, our specs now depend on the latest rack-test.
#
# In order to make setup simpler for folks, I'll put up some gemspecs on github
# and use their automatic building to provide development versions of these
# libraries as gems for easier deployment.
#
# Once the libraries are officially released in a usable state I'll switch
# dependencies to the official ones again.
#
# Please note that this makes running in environments that enforce their own
# Rack (like jruby-rack) still quite difficult, but should allow for easier
# development.
#
# Please be patient.

desc 'install all possible dependencies'
task :setup do
  GemInstaller.new do
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

    # mine
    gem 'manveru-innate',    '>= 2009.04.10', :lib => 'innate',    :source => github
    gem 'manveru-ezamar',    '>= 2009.03.10', :lib => 'ezamar',    :source => github
    gem 'manveru-nagoro',    '>= 2009.03.28', :lib => 'nagoro',    :source => github
    gem 'manveru-rack-test', '> 0.1.0',       :lib => 'rack-test', :source => github
    gem 'manveru-rack',      '>= 0.9.9',      :lib => 'rack',      :source => github

    setup
  end
end
