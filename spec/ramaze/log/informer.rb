require 'spec/helper'

describe 'Informer' do
  before do
    @out = []
    def @out.puts(*args) push(*args) end
    Ramaze::Logger::Informer.trait[:colorize] = false
    @inform = Ramaze::Logger::Informer.new(@out)
  end

  def format(tag, string)
    /\[\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\] #{tag.to_s.upcase.ljust(5)}  #{Regexp.escape(string)}/
  end

  it 'info' do
    @inform.info('Some Info')
    @out.first.should =~ format(:info, 'Some Info')
  end

  it 'debug' do
    arr = [:some, :stuff]
    @inform.debug(arr)
    @out.first.should =~ format(:debug, arr.inspect)
  end

  it 'warn' do
    @inform.warn('More things')
    @out.first.should =~ format(:warn, 'More things')
  end

  it 'error' do
    begin
      raise('Stuff')
    rescue => ex
    end

    @inform.error(ex)
    @out.first.should =~ format(:error, ex.inspect)
  end

  it 'should choose stdout on init(stdout,:stdout,STDOUT)' do
    a = Ramaze::Logger::Informer.new(STDOUT)
    b = Ramaze::Logger::Informer.new(:stdout)
    c = Ramaze::Logger::Informer.new('stdout')
    [a,b,c].each { |x| x.out.should == $stdout}
  end

  it 'should choose stderr on init(stderr,:stderr,STDERR)' do
    a = Ramaze::Logger::Informer.new(STDERR)
    b = Ramaze::Logger::Informer.new(:stderr)
    c = Ramaze::Logger::Informer.new('stderr')
    [a,b,c].each { |x| x.out.should == $stderr}
  end

  it 'should use IO when supplied' do
    i = Ramaze::Logger::Informer.new(s = StringIO.new)
    i.out.should == s
  end

  it 'should open file otherwise' do
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
