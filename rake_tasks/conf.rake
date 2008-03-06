AUTHOR = "manveru"
EMAIL = "m.fellinger@gmail.com"
DESCRIPTION = "Ramaze is a simple and modular web framework"
HOMEPATH = 'http://ramaze.rubyforge.org'
BIN_FILES = %w( ramaze )

BASEDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

NAME = "ramaze"
VERS = Ramaze::VERSION
COPYRIGHT = [
  "#          Copyright (c) #{Time.now.year} Michael Fellinger m.fellinger@gmail.com",
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
  rdoc
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

#{'=' * 60}
}.strip

AUTHOR_MAP = {
  'ahoward'                                 => 'Ara T. Howard',
  'ara.t.howard@gmail.com'                  => 'Ara T. Howard',
  'blueonyx@dev-area.net'                   => 'Martin Hilbig',
  'clive@crous.co.za'                       => 'Clive Crous',
  'comp.lang.zenix+ramaze@gmail.com'        => 'zenix',
  'jesusisramazing.10.pistos@geoshell.com'  => 'Pistos',
  'jesuswasramazing.10.pistos@geoshell.com' => 'Pistos',
  'keita.yamaguchi@gmail.com'               => 'Keita Yamaguchi',
  'leo.borisenko@gmail.com'                 => 'Leo Borisenko',
  'manveru@weez-int.com'                    => 'Michael Fellinger',
  'm.fellinger@gmail.com'                   => 'Michael Fellinger',
  'outtenr@gmail.com'                       => 'Richard Outten',
  'rff.rff@gmail.com'                       => 'Gabriele Renzi',
  'skaar@waste.org'                         => 'skaar',
  'stephan@spaceboyz.net'                   => 'Stephan Maka',
}

# * Browse and try the Examples in
#     #{File.join(Gem.path, 'gems', 'ramaze-' + VERS, 'examples')}
