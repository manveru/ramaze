require 'spec/helper'

describe 'Informer' do
  before(:each) do
    @out = []
    def @out.puts(*args) push(*args) end
    Ramaze::Informer.trait[:colorize] = false
    @inform = Ramaze::Informer.new(@out)
  end

  def format(tag, string)
    "[#{@inform.timestamp}] #{tag.to_s.upcase.ljust(5)}  #{string}"
  end

  it 'info' do
    @inform.info('Some Info')
    @out.first.should == format(:info, 'Some Info')
  end

  it 'debug' do
    arr = [:some, :stuff]
    @inform.debug(arr)
    @out.first.should == format(:debug, arr.inspect)
  end

  it 'warn' do
    @inform.warn('More things')
    @out.first.should == format(:warn, 'More things')
  end

  it 'error' do
    begin
      raise('Stuff')
    rescue => ex
    end

    @inform.error(ex)
    @out.first.should == format(:error, ex.inspect)
  end
end
