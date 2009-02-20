#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper
    EXPOSE = LOOKUP = Innate::Helper::EXPOSE
  end

  Innate::HelpersHelper.add_path(File.dirname(__FILE__))
  Innate::HelpersHelper.add_path('')
  Innate::HelpersHelper.add_pool(Ramaze::Helper)
end
