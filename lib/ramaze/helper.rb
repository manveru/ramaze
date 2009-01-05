#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper
    DEFAULT = Innate::Helper::DEFAULT
  end

  Innate::HelpersHelper.add_path(File.dirname(__FILE__))
  Innate::HelpersHelper.add_path('')
  Innate::HelpersHelper.add_pool(Ramaze::Helper)
end

# Require default helpers as far as we can find them.
# This is pure magic and way too DRY, anyone got a dispel handy?
Dir[Innate::HelpersHelper.glob].each do |file|
  require file if File.read(file) =~ /^\s*DEFAULT/
end
