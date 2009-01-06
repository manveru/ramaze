#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Namespace for Ramaze
#
# THINK:
#   * for now, we don't extend this with Innate to keep things clean. But we
#     should eventually do it for a simple API, or people always have to find
#     out whether something is in Innate or Ramaze.
#     No matter which way we go, we should keep references point to the
#     original location to avoid too much confusion for core developers.
module Ramaze
  ROOT = File.dirname(File.expand_path(__FILE__))

  unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == ROOT }
    $LOAD_PATH.unshift(ROOT)
  end
end

begin
  require 'rubygems'
rescue LoadError
end

# dependencies
require 'innate'

# stdlib

# bootstrap
require 'ramaze/version'
require 'ramaze/snippets'
require 'ramaze/log'
require 'ramaze/helper'
require 'ramaze/view'
require 'ramaze/controller'

module Ramaze
  def self.start(*args)
    Innate.start(*args)
  end
end
