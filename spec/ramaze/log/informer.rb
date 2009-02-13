require 'spec/helper'
require 'ramaze/log/informer'

describe 'Informer' do
  @out = []
  def @out.puts(*args) push(*args) end
  Ramaze::Logger::Informer.trait[:colorize] = false
  @inform = Ramaze::Logger::Informer.new(@out)

  def format(tag, string)
    /\[\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\] #{tag.to_s.upcase.ljust(5)}  #{Regexp.escape(string)}/
  end

  should 'log #info' do
    @inform.info('Some Info')
    @out.last.should =~ format(:info, 'Some Info')
  end

  should 'log #debug' do
    arr = [:some, :stuff]
    @inform.debug(arr)
    @out.last.should =~ format(:debug, arr.inspect)
  end

  should 'log #warn' do
    @inform.warn('More things')
    @out.last.should =~ format(:warn, 'More things')
  end

  should 'log #error' do
    begin
      raise('Stuff')
    rescue => ex
    end

    @inform.error(ex)
    @out[-16].should =~ format(:error, ex.inspect)
  end

  should 'choose stdout on init(stdout,:stdout,STDOUT)' do
    a = Ramaze::Logger::Informer.new(STDOUT)
    b = Ramaze::Logger::Informer.new(:stdout)
    c = Ramaze::Logger::Informer.new('stdout')
    [a,b,c].each { |x| x.out.should == $stdout}
  end

  should 'choose stderr on init(stderr,:stderr,STDERR)' do
    a = Ramaze::Logger::Informer.new(STDERR)
    b = Ramaze::Logger::Informer.new(:stderr)
    c = Ramaze::Logger::Informer.new('stderr')
    [a,b,c].each { |x| x.out.should == $stderr}
  end

  should 'use IO when supplied' do
    i = Ramaze::Logger::Informer.new(s = StringIO.new)
    i.out.should == s
  end

  should 'open file otherwise' do
    begin
      i = Ramaze::Logger::Informer.new('tmp.dummy')
      out = i.out
      out.should.be.instance_of(File)
      out.path.should == 'tmp.dummy'
    ensure
      out.close
      File.delete('tmp.dummy')
    end
  end
end
