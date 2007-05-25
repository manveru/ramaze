#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'nitro/helper/form'

module Ramaze

  # This helper simply includes the Nitro::FormHelper so you can use its methods
  # in your Controller.

  module NitroformHelper
    include ::Nitro::FormHelper
  end
end
