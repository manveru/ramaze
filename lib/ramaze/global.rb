#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/global/dsl'

module Ramaze
  GlobalDSL.option_dsl do
    o "Set the adapter Ramaze will run on.",
      :adapter => :webrick, :cli => [:webrick, :mongrel, :thin]

    o "All running threads of Adapter will be collected here.",
      :adapters => Set.new

    o "Set the size of Backtrace shown.",
      :backtrace_size => 10, :cli => 10

    o "Turn benchmarking every request on.",
      :benchmarking => false, :cli => false, :short => :b

    o "Do not log about these requests to static files, values as in Global.ignore",
      # Example: [/\.(ico|gif|jpg|png)$/, '/robots.txt']
      :boring => [ '/favicon.ico' ]

    o "Use this for general caching and as base for Cache.new.",
      :cache => :memory, :cli => [:memory, :memcached, :yaml]

    o "Alternative caches",
      :cache_alternative => {}

    o "Turn on naive caching of all requests.",
      :cache_all => false, :cli => false

    o "Compile Templates",
      :compile => false, :cli => false

    o "Active contribs ",
      :contribs => Set.new

    o "All subclasses of Controller are collected here.",
      :controllers => Set.new

    o "Start Ramaze within an IRB session",
      :console => false, :cli => false, :short => :c

    o "Turn on customized error pages.",
      :error_page => true, :cli => true

    o "Caching actions to the filesystem in Global.public_root",
      :file_cache => false, :cli => false

    o "Specify what IP Ramaze will respond to - 0.0.0.0 for all",
      :host => "0.0.0.0", :cli => '0.0.0.0'

    o "Ignore requests to these paths if no file in public_root exists, absolute path or regex",
      # Example: [/\.(ico|gif|jpg|png)$/, '/robots.txt']
      :ignore => [ '/favicon.ico' ]

    o "Body set on ignored paths",
      :ignore_body => "File not found"

    o "Status set on ignored paths",
      :ignore_status => 404

    o "Templating engines to load on startup",
      :load_engines => []

    o "All paths to controllers are mapped here.",
      :mapping => {}

    o "For your own modes to decide on",
      :mode => :live, :cli => [:live, :dev]

    o "The place ramaze was started from, useful mostly for debugging",
      :origin => :main

    o "Specify port",
      :port => 7000, :cli => 7000, :short => :p

    o "Specify directory to serve static files",
      :public_root => 'public', :cli => 'public'

    o "Record all Request objects by assigning a filtering Proc to me.",
      :record => false

    o "Don't wait until all adapter-threads are finished or killed.",
      :run_loose => false, :cli => false

    o "Turn on session for all requests.",
      :sessions => true, :cli => true

    o "Turn on BF/DoS protection for error-responses",
      :shield => false, :cli => false

    o "What signal to trap to call Ramaze::shutdown",
      :shutdown_trap => "SIGINT"

    o "Interval in seconds of the background SourceReload",
      :sourcereload => 3, :cli => 3

    o "How many adapters Ramaze should spawn.",
      :spawn => 1, :cli => 1, :short => :s

    o "Test before start if adapters will be able to connect",
      :test_connections => true, :cli => true

    o "Specify directory to serve dynamic files",
      :template_root => 'view', :cli => 'view'

    o "Enable directory listing",
      :list_directories => false, :cli => false

    o "Disable templates without actions",
      :actionless_templates => true, :cli => true
  end

  require 'ramaze/global/globalstruct'

  Global = GlobalStruct.setup(OPTIONS) unless defined?(Global)
end
