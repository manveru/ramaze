require 'spec/helper'

spec_require 'builder'

class TCTemplateBuilder < Ramaze::Controller
  view_root 'spec/ramaze/template/builder'
  map '/'
  engine :Builder

  def external
    @frameworks = { 'ramaze' => 'ruby',
                    'symfony' => 'php',
                    'django' => 'python' }
  end

  def internal
    external
    %q[
      @frameworks.each do |name, lang|
        xml.framework {|f| f.name(name); f.language(lang) }
      end
    ]
  end
end

describe "Builder" do
  behaves_like 'http'
  ramaze

  @xml = "<framework>
            <name>symfony</name>
            <language>php</language>
          </framework>
          <framework>
            <name>ramaze</name>
            <language>ruby</language>
          </framework>
          <framework>
            <name>django</name>
            <language>python</language>
          </framework>"

  @xml.gsub!(/\s/,'')

  it "should render xml from files" do
    r = get('/external')
    r.status.should == 200
    r.body.gsub(/\s/,'').should == @xml
    r.headers['Content-Type'].should == 'application/xml'
  end

  it 'should render internal templates' do
    get('/internal').body.gsub(/\s/,'').should == @xml
  end
end
