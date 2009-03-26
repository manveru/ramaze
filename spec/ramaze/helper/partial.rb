require 'spec/helper'
require 'ramaze/helper/partial'

class SpecHelperPartialMain < Ramaze::Controller
  layout :layout
  helper :partial
  engine :Ezamar
  map '/'

  def layout
    '[ #{@content} ]'
  end

  def entries
    @entries = ['Hello', 'World']

    '<?r @entries.each do |entry| ?>
      #{SpecHelperPartialSub.partial_content(:entry, :entry => entry).inspect}
     <?r end ?>'
  end
end

class SpecHelperPartialSub < SpecHelperPartialMain
  map '/sub'

  def entry
    @entry ||= 'Hello'

    'Entry: #{@entry}'
  end
end

describe 'Ramaze::Helper::Partial' do
  behaves_like :mock

  it 'renders partial content' do
    SpecHelperPartialSub.partial_content(:entry).should == 'Entry: Hello'
    SpecHelperPartialSub.partial_content(:entry, :entry => 'foo').should == 'Entry: foo'
  end
end
