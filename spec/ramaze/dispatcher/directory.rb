require 'spec/helper'

testcase_requires 'hpricot'

describe 'Dispatcher::Directory' do
  before :all do
    ramaze

    @hierarchy = %w[
    /test/deep/hierarchy/one.txt
    /test/deep/hierarchy/two.txt
    /test/deep/three.txt
    /test/deep/four.txt
    /test/five.txt
    /test/six.txt ]

    @hierarchy.each do |path|
      FileUtils.mkdir_p(__DIR__/:public/File.dirname(path))
      FileUtils.touch(__DIR__/:public/path)
    end
  end

  def build_listing(path)
    Ramaze::Dispatcher::Directory.build_listing(path)
  end

  it 'should dry serve root directory' do
    body, status, header = build_listing('/')
    status.should == 200
    header['Content-Type'].should == 'text/html'
    doc = Hpricot(body)
    doc.at(:title).inner_text.should == 'Directory listing of /'
    files = doc.search("//td[@class='n']")
    links = files.map{|td| a = td.at(:a); [a['href'], a.inner_text]}
    links.should == [["/../", "Parent Directory"], ["/test", "test/"],
      ["/favicon.ico", "favicon.ico"], ["/test_download.css", "test_download.css"]]
  end

  it 'should serve hierarchies' do
    body, status, header = build_listing('/test')
    status.should == 200
    header['Content-Type'].should == 'text/html'
    doc = Hpricot(body)
    doc.at(:title).inner_text.should == 'Directory listing of /test'
    files = doc.search("//td[@class='n']")
    links = files.map{|td| a = td.at(:a); [a['href'], a.inner_text]}
    links.should == [["/test/../", "Parent Directory"], ["/test/deep", "deep/"],
      ["/test/five.txt", "five.txt"], ["/test/six.txt", "six.txt"]]
  end

  after :all do
    FileUtils.rm_rf(__DIR__/:public/:test)
  end
end
