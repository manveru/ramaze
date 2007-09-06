require 'spec/helper'

describe "Numeric#human_readable_filesize_format" do
  it 'it should convert filesizes to human readable format' do
    1.human_readable_filesize_format.should == '1'
    1024.human_readable_filesize_format.should == '1.0K'
    (1 << 20).human_readable_filesize_format.should == '1.0M'
    (1 << 20).human_readable_filesize_format.should == '1.0M'
    (1 << 30).human_readable_filesize_format.should == '1.0G'
    (1 << 40).human_readable_filesize_format.should == '1.0T'
  end
end
