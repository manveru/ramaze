module Ramaze
  module CacheHelper
    def invalidate_cache
      p :invalidate
      Global.out_cache ||= {}
      Global.out_cache.clear
    end
  end
end
