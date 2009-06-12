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

# To release the monthly version do:
# $ VERSION=2009.03 rake release

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

  s.add_dependency('innate', '= 2009.06.12')

  # rip those out if they cause you trouble
  s.add_development_dependency('Remarkably',      '~> 0.5.2')
  s.add_development_dependency('bacon',           '>= 1.1.0')
  s.add_development_dependency('erubis',          '>= 2.6.4')
  s.add_development_dependency('ezamar',          '>= 2009.06')
  s.add_development_dependency('haml',            '~> 2.0.9')
  s.add_development_dependency('hpricot',         '>= 0.8.1')
  s.add_development_dependency('json',            '>= 1.1.6')
  s.add_development_dependency('liquid',          '~> 2.0.0')
  s.add_development_dependency('localmemcache',   '~> 0.4.0')
  s.add_development_dependency('memcache-client', '~> 1.7.2')
  s.add_development_dependency('nagoro',          '>= 2009.05')
  s.add_development_dependency('rack-test',       '>= 0.3.0')
  s.add_development_dependency('sequel',          '=  3.1.0')
  s.add_development_dependency('tagz',            '>= 5.0.1')
  s.add_development_dependency('tenjin',          '~> 0.6.1')

  s.post_install_message = <<MESSAGE.strip
============================================================

Thank you for installing Ramaze!
You can now do create a new project:
# ramaze create yourproject

============================================================
MESSAGE
}

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
