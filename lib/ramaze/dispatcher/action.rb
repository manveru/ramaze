require 'ramaze/tool/tidy'

module Ramaze
  module Dispatcher
    class Action

      # The response is passed to each

      trait :filter => [ Ramaze::Tool::Tidy ]

      class << self
        def process(path)
          body = Controller.handle(path)
          response = Dispatcher.build_response(body)
          filter = ancestral_trait[:filter]
          filter.inject(response){|r,f| f.call(r) }
        end
      end
    end
  end
end
