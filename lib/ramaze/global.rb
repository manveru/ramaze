#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

require 'ramaze/global/dsl'

module Ramaze
  GlobalDSL.option_dsl do
    o "Set the adapter Ramaze will run on.",
      :adapter => :webrick, :cli => [:webrick, :mongrel]

    o "All running threads of Adapter will be collected here.",
      :adapters => Set.new

    o "Set the size of Backtrace shown.",
      :backtrace_size => 10, :cli => 10

    o "Turn benchmarking every request on.",
      :benchmarking => false, :cli => false

    o "Use this for general caching and as base for Cache.new.",
      :cache => :memory, :cli => [:memory, :memcached, :yaml]

    o "Turn on naive caching of all requests.",
      :cache_all => false, :cli => false

    o "Turn on cookies for all requests.",
      :cookies => true, :cli => true

    o "All subclasses of Controller are collected here.",
      :controllers => Set.new

    o "Start Ramaze within an IRB session",
      :console => false, :cli => false

    o "Turn on customized error pages.",
      :error_page => true, :cli => true

    o "Specify what IP Ramaze will respond to - 0.0.0.0 for all",
      :host => "0.0.0.0", :cli => '0.0.0.0'

    o "All paths to controllers are mapped here.",
      :mapping => {}

    o "Specify port",
      :port => 7000, :cli => 7000

    o "Specify the shadowing public directory (default in proto)",
      :public_root => ( BASEDIR / 'proto' / 'public' )

    o "Record all Request objects by assigning a filtering Proc to me.",
      :record => false

    o "Don't wait until all adapter-threads are finished or killed.",
      :run_loose => false, :cli => false

    o "Turn on BF/DoS protection for error-responses",
      :shield => false, :cli => false

    o "What signal to trap to call Ramaze::shutdown",
      :shutdown_trap => "SIGINT"

    o "Interval in seconds of the background SourceReload",
      :sourcereload => 3, :cli => 3

    o "How many adapters Ramaze should spawn.",
      :spawn => 1, :cli => 1

    o "Test before start if adapters will be able to connect",
      :test_connections => true, :cli => true

    o "Specify template root for dynamic files relative to main.rb",
      :template_root => 'template'
  end

  require 'ramaze/global/globalstruct'

  Global = GlobalStruct.setup(OPTIONS)

  def Global.startup(options = {})
    options.each do |key, value|
      if (method(key) rescue false)
        self[key] = value
      else
        create_member(key, value)
      end
    end
  end
end
