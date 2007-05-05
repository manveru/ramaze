require 'spec/helper'

require 'examples/caching.rb'

describe 'Caching' do
  ramaze

  it '/' do
    n1 = 10_000
    n2 = 10_000
    result = n1 ** n2
    url = "/#{n1}/#{n2}"
    result_string = "Hello, i'm a little method with this calculation:\n#{n1} ** #{n2} = #{result}"

    get(url).body.should == result_string

    intense_time = Benchmark.realtime{ get(url).body.should == result_string }
    cached_already = Benchmark.realtime{ get(url) }
    intense_time.should be > cached_already
  end
end
