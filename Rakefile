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
PROJECT_VERSION     = (ENV['VERSION'] || Date.today.strftime('%Y.%m.%d')).dup
PROJECT_COPYRIGHT   = [
  "#          Copyright (c) #{Time.now.year} Michael Fellinger m.fellinger@gmail.com",
  "# All files in this distribution are subject to the terms of the Ruby license."
]

DEPENDENCIES = {
  'innate' => {:version => '>= 2010.03'},
}

DEVELOPMENT_DEPENDENCIES = {
  "abstract"   	            => {:version => "1.0.0"},
  "addressable"             => {:version => "2.1.1"},
  "bacon"                   => {:version => "1.1.0"},
  "builder"                 => {:version => "2.1.2"},
  "erector"                 => {:version => "0.7.2"},
  "erubis"                  => {:version => "2.6.5"},
  "ezamar"                  => {:version => "2009.06"},
  "haml"                    => {:version => "2.2.22"},
  "hpricot"                 => {:version => "0.8.2"},
  "json"                    => {:version => "1.2.3"},
  "less"                    => {:version => "1.2.21"},
  "liquid"                  => {:version => "2.0.0"},
  "locale"                  => {:version => "2.0.5"},
  "localmemcache"           => {:version => "0.4.4"},
  "lokar"                   => {:version => "0.1.0"},
  "maruku"                  => {:version => "0.6.0"},
  "memcache-client"         => {:version => "1.8.1", :lib => 'memcache'},
  "mustache"                => {:version => "0.9.2"},
  "mutter"                  => {:version => "0.5.3"},
  "nagoro"                  => {:version => "2009.05"},
  "rack-contrib"            => {:version => "0.9.2", :lib => 'rack/contrib'},
  "rack-test"               => {:version => "0.5.3", :lib => 'rack/test'},
  "RedCloth"                => {:version => "4.2.3"},
  "Remarkably"              => {:version => "0.5.2", :lib => 'remarkably'},
  "RubyInline"              => {:version => "3.8.4"},
  "sequel"                  => {:version => "3.9.0"},
  "scaffolding_extensions"  => {:version => "1.4.0"},
  "slippers"                => {:version => "0.0.14"},
  "sqlite3-ruby"            => {:version => "1.2.5", :lib => 'sqlite3'},
  "tagz"                    => {:version => "7.2.3"},
  "tenjin"                  => {:version => "0.6.1"},
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
  s.required_rubygems_version = '>= 1.3.5'

  s.post_install_message = <<MESSAGE.strip
============================================================

Thank you for installing Ramaze!
To create a new project:
$ ramaze create yourproject

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
