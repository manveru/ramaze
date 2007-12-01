require __DIR__/:facebook/:facebook

module Ramaze
  module FacebookHelper
    def self.included(klass)
      klass.send(:helper, :aspect, :inform)
    end

    def error
      if Facebook::ADMINS.include? facebook[:user]
        error = Ramaze::Dispatcher::Error.current
        [error, *error.backtrace].join '<br/>'
      end
    end

    private

    def facebook
      @facebook ||= Facebook::Client.new
    end
    alias fb facebook
  end
end