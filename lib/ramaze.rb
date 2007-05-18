#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))
  $:.unshift BASEDIR
end

Thread.abort_on_exception = true

# Bootstrap
require 'ramaze/version'
require 'ramaze/snippets'
require 'ramaze/inform'
require 'ramaze/global'
require 'ramaze/cache'

# Startup
require 'ramaze/controller'
require 'ramaze/adapter'
require 'ramaze/sourcereload'

# Complete
require 'ramaze/dispatcher'
require 'ramaze/template/ezamar'

module Ramaze
  trait :essentials => [
    Global, Controller, SourceReload, Adapter
  ]

  class << self
    def startup options = {}
      Inform.info("Starting up Ramaze (Version #{VERSION})")

      starter = caller[0].split(':').first
      return unless ($0 == starter or options.delete(:force))

      options[:origin] ||= :main

      trait[:essentials].each do |obj|
        obj.startup(options)
      end
    end

    def shutdown
      trait[:essentials].each do |obj|
        obj.shutdown if obj.respond_to?(:shutdown)
      end

      puts("Shutdown Ramaze (it's save to kill me now if i hang)")

      exit!
    end

    alias start startup
    alias stop shutdown
  end
end
