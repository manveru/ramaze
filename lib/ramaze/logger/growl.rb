#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ruby-growl'

module Ramaze
  
  class Growl < ::Growl
    
    trait :name => 'walrus'
    trait :host => 'localhost'
    trait :password => 'walrus'
    trait :all_notifies => %w(error warn debug info)
    trait :default_notifies => %w(error warn info)
    
    trait[:all_notifies].each do |meth,foo|
      define_method(meth) do |*args|
        title = (args.size > 1 ? args.shift : '')
        notify(meth, title, args.join("\n"))
      end
      
      define_method("#{meth}?") do |*args|
        inform_tag?(meth)
      end
    end
    
    # Webrick
    
    def <<(*args)
      debug(args)
    end
    
    class << self
      def startup
        name, host, pass, all, default = trait.values_at(:name, :host, :password, :all_notifies, :default_notifies)
        @instance ||= Growl.new(host, name, all, default, pass)
      end
    end
    
    def inform_tag?(inform_tag)
      trait[:default_notifies].include?(inform_tag)
    end
    
  end
  
end
