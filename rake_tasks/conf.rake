AUTHOR = "manveru"
EMAIL = "m.fellinger@gmail.com"
DESCRIPTION = "Ramaze tries to be a very simple Webframework without the voodoo"
HOMEPATH = 'http://ramaze.rubyforge.org'
BIN_FILES = %w( ramaze )

BASEDIR = File.dirname(__FILE__)

NAME = "ramaze"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Ramaze::VERSION + (REV ? ".#{REV}" : ""))
COPYRIGHT = [
  "#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com",
  "# All files in this distribution are subject to the terms of the Ruby license."
]
CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  *.yaml
  pkg
]
RDOC_OPTS = %w[
  --all
  --quiet
  --op rdoc
  --line-numbers
  --inline-source
  --main doc/README
  --opname index.html
  --title "Ramaze\ documentation"
  --exclude "^(_darcs|spec|examples|bin|pkg)/"
  --exclude "lib/proto"
  --include "doc"
  --accessor "trait"
]
RDOC_FILES = %w[
  lib doc doc/README doc/FAQ doc/CHANGELOG
]
POST_INSTALL_MESSAGE = %{
#{'=' * 60}

Thank you for installing Ramaze!
You can now do following:

* Create a new project using the `ramaze' command:
    ramaze --create yourproject

* Browse and try the Examples in
    #{File.join(Gem.path, 'gems', 'ramaze-' + VERS, 'examples')}

#{'=' * 60}
}.strip
