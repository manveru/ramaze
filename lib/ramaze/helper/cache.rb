#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze
  module CacheHelper
    def invalidate_cache
      p :invalidate
      Global.out_cache ||= {}
      Global.out_cache.clear
    end
  end
end
