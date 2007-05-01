require 'spec/helper'

require 'examples/caching.rb'

context 'Caching' do
  ramaze

  specify do
    n1 = 10_000
    n2 = 10_000
    result = n1 ** n2
    url = "/#{n1}/#{n2}"
    result_string = "Hello, i'm a little method with this calculation:\n#{n1} ** #{n2} = #{result}"

    get(url).should == result_string

    timeframe = Benchmark.realtime{ get(url).should == result_string }
    timeframe += 0.2

    lambda{ Timeout.timeout(timeframe){ get(url).should == result_string } }.should_not_raise Timeout::Error
    lambda{ Timeout.timeout(timeframe){ get('/').should_not != result_string } }.should_raise Timeout::Error
  end
end
