require 'ramaze'
require 'test/test_helper'

context "all testcases" do
  def gestalt &block
    Ramaze::Gestalt.new(&block).to_s
  end

  specify "simple tag" do
    gestalt{ br }.should_equal '<br />'
    gestalt{ p }.should_equal '<p />'
  end

  specify "open close tags" do
    gestalt{ p{} }.should_equal '<p></p>'
    gestalt{ div{} }.should_equal '<div></div>'
  end

  specify "nested tags" do
    gestalt{ p{ br } }.should_equal '<p><br /></p>'
  end

  specify "deep nested tags" do
    gestalt{ p do
      div do
        ol do
          li 
        end 
      end 
    end
    }.should_equal '<p><div><ol><li /></ol></div></p>'
  end

  specify "deep nested tags with repetition" do
    gestalt{ p do
      div do 
        ol do
          li
          li
        end
        ol do 
          li
          li
        end
      end
    end
    }.should_equal '<p><div><ol><li /><li /></ol><ol><li /><li /></ol></div></p>'
  end

  specify "deep nested tags with strings" do
    gestalt{
      p do
      div do
       'Hello, World'
      end
    end
    }.should_equal '<p><div>Hello, World</div></p>'
  end

  specify "some simple example" do
    gestalt{
      html do
        head do
          title do
            "Hello World"
          end
        end
        body do
          h1 do
            "Hello World"
          end
        end
      end
    }.should_equal '<html><head><title>Hello World</title></head><body><h1>Hello World</h1></body></html>'
  end

  specify "now some ruby inside" do
    gestalt do
      table do
        tr do
          %w[one two three].each do |s|
            td{s}
          end
        end
      end
    end.should_equal '<table><tr><td>one</td><td>two</td><td>three</td></tr></table>'
  end
end
