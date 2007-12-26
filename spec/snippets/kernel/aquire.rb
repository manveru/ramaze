require 'spec'
require File.expand_path(__FILE__).gsub('/spec/', '/lib/ramaze/')
require 'fileutils'

describe 'aquire' do
  def require(name)
    @required << name
  end

  before :all do
    FileUtils.mkdir_p 'tmp_dir_for_aquire/sub'
    FileUtils.touch 'tmp_dir_for_aquire/foo.rb'
    FileUtils.touch 'tmp_dir_for_aquire/bar.rb'
    FileUtils.touch 'tmp_dir_for_aquire/baz.so'
    FileUtils.touch 'tmp_dir_for_aquire/baz.yml'
    FileUtils.touch 'tmp_dir_for_aquire/sub/baz.rb'
  end

  before do
    @required = []
  end

  it 'should not load a single file' do
    aquire 'tmp_dir_for_aquire/foo'
    @required.should == []
  end

  it 'should load dir' do
    aquire 'tmp_dir_for_aquire/sub/*'
    @required.should == ['tmp_dir_for_aquire/sub/baz.rb']
  end

  it 'should load {so,rb}, not others' do
    aquire 'tmp_dir_for_aquire/*'
    @required.sort.should == %w{
                              tmp_dir_for_aquire/bar.rb
                              tmp_dir_for_aquire/baz.so
                              tmp_dir_for_aquire/foo.rb}

  end

  it 'should use globbing' do
    aquire 'tmp_dir_for_aquire/ba*'
    @required.sort.should == %w{
                              tmp_dir_for_aquire/bar.rb
                              tmp_dir_for_aquire/baz.so}

  end

  it 'should use recursive globbing' do
    aquire 'tmp_dir_for_aquire/**/*'
    @required.sort.should == %w{
                              tmp_dir_for_aquire/bar.rb
                              tmp_dir_for_aquire/baz.so
                              tmp_dir_for_aquire/foo.rb
                              tmp_dir_for_aquire/sub/baz.rb}

  end

  it 'should accept multiple arguments' do
    aquire 'tmp_dir_for_aquire/*', 'tmp_dir_for_aquire/sub/*'
    @required.sort.should == %w{
                              tmp_dir_for_aquire/bar.rb
                              tmp_dir_for_aquire/baz.so
                              tmp_dir_for_aquire/foo.rb
                              tmp_dir_for_aquire/sub/baz.rb}

  end

  after :all do
    FileUtils.rm_rf('tmp_dir_for_aquire')
  end
end
