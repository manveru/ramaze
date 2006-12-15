#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Global
    class << self
      # The default variables for Global:
      #   uses the class from Adapter:: (is required automatically)
      #       Global.adapter #=> :webrick
      #   restrict access to a specific host
      #       Global.host #=> '0.0.0.0'
      #   adapter runs on that port
      #       Global.port #=> 7000
      #   the running/debugging-mode (:debug|:stage|:live|:silent) - atm only differ in verbosity
      #       Global.mode #=> :debug
      #   detaches Ramaze to run in the background (used for testcases)
      #       Global.run_loose #=> false
      #   caches requests to the controller based on request-values (action/params)
      #       Global.cache #=> false
      #   run tidy over the generated html if Content-Type is text/html
      #       Global.tidy #=> false
      #   display an error-page with backtrace on errors (empty page otherwise)
      #       Global.error_page    #=> true
      #   trap this signal for clean shutdown (calls Ramaze.shutdown)
      #       Global.shutdown_trap #=> 'SIGINT'

      DEFAULT_OPTIONS = {
        :host           => '0.0.0.0',
        :port           => 7000,
        :mode           => :debug,
        :tidy           => false,
        :cache          => false,
        :adapter        => :webrick,
        :run_loose      => false,
        :error_page     => true,
        :template_root  => 'template',

        :autoreload => {
          :benchmark  => 5,
          :debug      => 5,
          :stage      => 10,
          :live       => 20,
          :silent     => 40,
        },
        :logger => {
          :timestamp    => "%Y-%m-%d %H:%M:%S",
          :prefix_info  => 'INFO',
          :prefix_error => 'ERRO',
          :prefix_debug => 'DEBG',
        }
      }

      @@table = {}

      def create(h = {})
        @@table = Thread.main[:global] = h
      end

      def table
        @@table
      end

      def setup hash = DEFAULT_OPTIONS
        create
        update hash
      end

      def update(h = {})
        create unless @@table
        @@table = h.merge(@@table)
      end

      def [](key)
        @@table[key.to_sym]
      end

      def []=(key, value)
        @@table[key.to_sym] = value
      end

      def method_missing(meth, *args, &block)
        if meth.to_s[-1..-1] == '='
          key = meth.to_s[0..-2].to_sym
          @@table.send("[]=", key, *args)
          class_eval %{
            def #{key}
              @@table[#{key}]
            end
          }
          self.send(key)
        elsif args.empty?
          @@table[meth] ||= nil
        else
          @@table.send(meth, *args, &block)
        end
      rescue => ex
        nil
      end

      def inspect
        @@table.inspect
      end

      def pretty_inspect
        @@table.pretty_inspect
      end

    end # class << self

  end # Global
end # Ramaze
