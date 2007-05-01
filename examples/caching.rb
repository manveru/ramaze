require 'ramaze'

include Ramaze

class MainController < Controller
  map '/'
  helper :cache
  trait :actions_cached => [:index]

  def index(n1 = 100_000, n2 = 100_00)
    %[
Hello, i'm a little method with this calculation:
#{n1} ** #{n2} = #{n1.to_i ** n2.to_i}
    ].strip
  end

  def invalidate
    action_cache.clear
  end
end
