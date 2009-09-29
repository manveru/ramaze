begin; require 'rubygems'; rescue LoadError; end

require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'time'
require 'date'

PROJECT_SPECS = FileList[
  'spec/{contrib,examples,ramaze,snippets}/**/*.rb',
  'lib/proto/spec/*.rb'
]

PROJECT_MODULE      = 'Ramaze'
PROJECT_JQUERY_FILE = 'lib/proto/public/js/jquery.js'
PROJECT_README      = 'README.md'
PROJECT_VERSION     = ENV['VERSION'] || Date.today.strftime('%Y.%m.%d')
PROJECT_COPYRIGHT   = [
  "#          Copyright (c) #{Time.now.year} Michael Fellinger m.fellinger@gmail.com",
  "# All files in this distribution are subject to the terms of the Ruby license."
]

DEPENDENCIES = {
  'innate' => {:version => '= 2009.07'},
}

DEVELOPMENT_DEPENDENCIES = {
  'RedCloth'         => {:version => '~> 4.2.2'},
  'Remarkably'       => {:version => '~> 0.5.2', :lib => 'remarkably'},
  'activesupport'    => {:version => '~> 2.3.4'},
  'addressable'      => {:version => '~> 2.1.0'},
  'bacon'            => {:version => '>= 1.1.0'},
  'erector'          => {:version => '~> 0.7.0'},
  'erubis'           => {:version => '>= 2.6.4'},
  'ezamar'           => {:version => '>= 2009.06'},
  'haml'             => {:version => '~> 2.2.1'},
  'hpricot'          => {:version => '>= 0.8.1'},
  'json'             => {:version => '>= 1.1.7'},
  'less'             => {:version => '~> 1.1.13'},
  'liquid'           => {:version => '~> 2.0.0'},
  'locale'           => {:version => '~> 2.0.4'},
  'localmemcache'    => {:version => '~> 0.4.1'},
  'maruku'           => {:version => '~> 0.6.0'},
  'memcache-client'  => {:version => '~> 1.7.4', :lib => 'memcache'},
  'nagoro'           => {:version => '>= 2009.05'},
  'rack-contrib'     => {:version => '>= 0.9.2', :lib => 'rack/contrib'},
  'rack-test'        => {:version => '>= 0.4.0', :lib => 'rack/test'},
  'sequel'           => {:version => '=  3.2.0'},
  'slippers'         => {:version => '~> 0.0.10'},
  'sqlite3-ruby'     => {:version => '~> 1.2.5', :lib => 'sqlite3'},
  'tagz'             => {:version => '>= 7.1.0'},
  'tenjin'           => {:version => '~> 0.6.1'},
}

GEMSPEC = Gem::Specification.new{|s|
  s.name         = 'ramaze'
  s.author       = "Michael 'manveru' Fellinger"
  s.summary      = "Ramaze is a simple and modular web framework"
  s.description  = s.summary
  s.email        = 'm.fellinger@gmail.com'
  s.homepage     = 'http://ramaze.net'
  s.platform     = Gem::Platform::RUBY
  s.version      = PROJECT_VERSION
  s.files        = `git ls-files`.split("\n").sort
  s.has_rdoc     = true
  s.require_path = 'lib'
  s.bindir       = "bin"
  s.executables  = ["ramaze"]
  s.rubyforge_project = "ramaze"
  s.required_rubygems_version = '>= 1.3.1'

  s.post_install_message = <<MESSAGE.strip
============================================================

Thank you for installing Ramaze!
You can now do create a new project:
# ramaze create yourproject

============================================================
MESSAGE
}

DEPENDENCIES.each do |name, options|
  GEMSPEC.add_dependency(name, options[:version])
end

DEVELOPMENT_DEPENDENCIES.each do |name, options|
  GEMSPEC.add_development_dependency(name, options[:version])
end

Dir['tasks/*.rake'].each{|f| import(f) }

task :default => [:bacon]

CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  *.yaml
  pkg
  rdoc
  ydoc
  *coverage*
]
