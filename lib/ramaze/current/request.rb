#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # The purpose of this class is to act as a simple wrapper for Rack::Request
  # and provide some convinient methods for our own use.
  class Request < Innate::Request
    # Currently active request out of STATE[:request]
    def self.current; Current.request; end

    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request

    def method_missing meth, *args
      key = meth.to_s.upcase
      return env[key] if env.has_key?(key)
      super
    end

    # Sets any arguments passed as @instance_variables for the current action.
    #
    # Usage:
    #   request.params # => {'name' => 'manveru', 'q' => 'google', 'lang' => 'de'}
    #   to_ivs(:name, :q)
    #   @q    # => 'google'
    #   @name # => 'manveru'
    #   @lang # => nil

    def to_ivs(*args)
      instance = Action.current.instance
      args.each do |arg|
        next unless value = self[arg]
        instance.instance_variable_set("@#{arg}", value)
      end
    end
  end
end
