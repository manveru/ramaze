#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'tidy', 'ramaze/tool/tidy'

include Ramaze::Tool::Tidy

context "testing tidy" do
  specify "tidy some simple html" do
    tidy("<html></html>").should =~ %r{<html>\s+<head>\s+<meta name="generator" content="HTML Tidy (.*?)" />\s+<title></title>\s+</head>\s+<body></body>\s+</html>}
  end
end
