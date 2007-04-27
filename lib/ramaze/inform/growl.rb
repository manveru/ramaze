#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ruby-growl'

module Ramaze
  class Growl < ::Growl

    trait :defaults => {
      :name => 'walrus',
      :host => 'localhost',
      :password => 'walrus',
      :all_notifies => %w[error warn debug info],
      :default_notifies => %w[error warn info],
    }

    def initialize(options = {})
      options = trait[:defaults].merge(options)
      super(options.values_at(:host, :name, :all_notifies, :default_notifies, :pass)
    end

    def inform(tag, *args)
      notify(tag.to_s, tag.to_sym, args.join("\n"))
    end
  end
end
