#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'tidy', 'ramaze/tool/tidy'

describe "testing tidy" do
  it "tidy some simple html" do
    Ramaze::Tool::Tidy.tidy("<html></html>").
      should =~ %r{<html>\s+<head>\s+<meta name="generator" content="HTML Tidy (.*?)" />\s+<title></title>\s+</head>\s+<body></body>\s+</html>}
  end
end
