#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'

module Ramaze::Template
  %w[ Ramaze Amrita2 Erubis Markaby ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end
end
