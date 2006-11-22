require 'ramaze'
require 'test/test_helper'

require 'ramaze/tool/tidy'

include Ramaze::Tool::Tidy

context "testing tidy" do
  specify "tidy some simple html" do
    tidy("<html></html>").should =~ %r{<html>\s+<head>\s+<meta name="generator" content="HTML Tidy (.*?)" />\s+<title></title>\s+</head>\s+<body></body>\s+</html>}
  end
end
