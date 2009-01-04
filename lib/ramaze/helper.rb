#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper
  end

  Innate::HelpersHelper.add_path(File.dirname(__FILE__))
  Innate::HelpersHelper.add_path('')
  Innate::HelpersHelper.add_pool(Ramaze::Helper)
end
