require 'ramaze'

include Ramaze

class MainController < Controller
  helper :cache

  trait :actions_cached => [:index]

  def index
    calc = "100_000 ** 100_00"
    %[
      Hello, i'm a little method with this calculation:
      #{calc} = #{eval(calc)}
    ]
  end

  def invalidate
    action_cache.clear
  end
end

run
