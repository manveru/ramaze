#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # The general Namespace for Ramazes Errorclasses

  module Error
    # No action found on Controller
    class NoAction < StandardError; end

    # No Controller found for request
    class NoController < StandardError; end

    # Wrong parameter count for action
    class WrongParameterCount < StandardError; end

    # Error while transformation in template
    class Template < StandardError; end
  end
end
