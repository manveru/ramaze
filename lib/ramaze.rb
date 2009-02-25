#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
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
  ROOT = File.expand_path(File.dirname(__FILE__)) unless defined?(Ramaze::ROOT)

  unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == ROOT }
    $LOAD_PATH.unshift(ROOT)
  end

  # 3rd party
  require 'innate'

  # vendored, will go into rack-contrib
  require 'vendor/etag'
  require 'vendor/route_exceptions'

  # Ramaze itself
  require 'ramaze/version'
  require 'ramaze/log'
  require 'ramaze/snippets'
  require 'ramaze/helper'
  require 'ramaze/view'
  require 'ramaze/controller'
  require 'ramaze/cache'
  require 'ramaze/reloader'
  require 'ramaze/setup'

  # Usually it's just mental overhead to remember which module has which
  # constant, so we just assign them here as well.
  # This will not affect any of the module functions on Innate, you still have
  # to reference the correct module for them.
  # We do not set constants already set from the requires above.
  Innate.constants.each do |const|
    begin
      Ramaze.const_get(const)
    rescue NameError
      Ramaze.const_set(const, Innate.const_get(const))
    end
  end

  extend Innate::SingletonMethods

  @options = Innate.options
  class << self; attr_accessor :options; end

  middleware! :dev do |m|
    m.use(Rack::Lint,
          Ramaze::Reloader,
          Rack::ShowStatus,
          Rack::RouteExceptions,
          Rack::ShowExceptions,
          Rack::Head,
          Rack::ETag,
          Rack::ConditionalGet,
          Rack::CommonLogger)
    m.innate
  end

  middleware! :live do |m|
    m.use(Rack::CommonLogger,
          Rack::RouteExceptions,
          Rack::ShowStatus,
          Rack::ShowExceptions,
          Rack::Head,
          Rack::ETag,
          Rack::ConditionalGet)
    m.innate
  end
end
