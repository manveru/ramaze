#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'innate/cache'

module Ramaze
  Cache = Innate::Cache

  class Cache
    autoload :MemCache, 'ramaze/cache/memcache'
  end
end
