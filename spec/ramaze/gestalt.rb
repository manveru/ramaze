#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

describe "Gestalt" do
  def gestalt &block
    Ramaze::Gestalt.new(&block).to_s
  end

  it "simple tag" do
    gestalt{ br }.should == '<br />'
    gestalt{ p }.should == '<p />'
  end

  it "open close tags" do
    gestalt{ p{} }.should == '<p></p>'
    gestalt{ div{} }.should == '<div></div>'
  end

  it "nested tags" do
    gestalt{ p{ br } }.should == '<p><br /></p>'
  end

  it "deep nested tags" do
    gestalt{ p do
      div do
        ol do
          li
        end
      end
    end
    }.should == '<p><div><ol><li /></ol></div></p>'
  end

  it "deep nested tags with repetition" do
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
    }.should == '<p><div><ol><li /><li /></ol><ol><li /><li /></ol></div></p>'
  end

  it "deep nested tags with strings" do
    gestalt{
      p do
      div do
       'Hello, World'
      end
    end
    }.should == '<p><div>Hello, World</div></p>'
  end

  it "some simple example" do
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
    }.should == '<html><head><title>Hello World</title></head><body><h1>Hello World</h1></body></html>'
  end

  it "now some ruby inside" do
    gestalt{
      table do
        tr do
          %w[one two three].each do |s|
            td{s}
          end
        end
      end
    }.should == '<table><tr><td>one</td><td>two</td><td>three</td></tr></table>'
  end
end
