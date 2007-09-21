#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

begin
  require 'rubygems'
rescue LoadError
end

# The main namespace for Ramaze
module Ramaze
  BASEDIR = File.dirname(File.expand_path(__FILE__))
  SEEED = $0.dup
  $:.unshift BASEDIR
end

Thread.abort_on_exception = true

# Bootstrap
require 'ramaze/version'
require 'ramaze/snippets'
require 'ramaze/inform'
require 'ramaze/global'
require 'ramaze/cache'
require 'ramaze/tool'

# Startup
require 'ramaze/controller'
require 'ramaze/adapter'
require 'ramaze/sourcereload'

# Complete
require 'ramaze/dispatcher'
require 'ramaze/template/ezamar'

module Ramaze

  # Each of these classes will be called ::startup upon Ramaze.startup

  trait :essentials => [
    Global, Cache, Controller, Session, SourceReload, Adapter
  ]

  class << self

    # The one place to start Ramaze, takes an Hash of options to pass on to
    # each class in trait[:essentials] by calling ::startup on them.

    def startup options = {}
      starter = caller[0].split(':').first

      if $0 == starter or options.delete(:force)
        Inform.info("Starting up Ramaze (Version #{VERSION})")
        SEEED.replace(starter)

        trait[:essentials].each do |obj|
          obj.startup(options)
        end
      end
    end

    # This will be called when you hit ^C or send SIGINT.
    # It sends ::shutdown to every class in trait[:essentials] and informs you
    # when it is done

    def shutdown
      trait[:essentials].each do |obj|
        obj.shutdown if obj.respond_to?(:shutdown)
      end

      puts("Shutdown Ramaze (it's safe to kill me now if i hang)")

      exit!
    end

    alias start startup
    alias stop shutdown
  end
end
