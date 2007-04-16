#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/tool/tidy'
require 'ramaze/tool/localize'

module Ramaze
  module Dispatcher
    class Action

      # The response is passed to each filter by sending .call(response) to it.

      trait :filter => [
        Ramaze::Tool::Localize,
        Ramaze::Tool::Tidy
      ]

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
