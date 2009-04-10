# * Encoding: UTF-8
$KCODE = 'u' if //.respond_to?(:kcode)
require 'spec/helper'
spec_requires 'locale/tag', 'locale'

class SpecHelperLocalize < Ramaze::Controller
  map '/'
  helper :localize

  def index
    locale.language
  end

  def translate(string)
    l(string)
  end

  private

  def localize_dictionary
    DICTIONARY
  end
end

DICTIONARY = Ramaze::Helper::Localize::Dictionary.new
DICTIONARY.load(:en, :hash => {'one' => 'one',  'two' => 'two'})
DICTIONARY.load(:de, :hash => {'one' => 'eins', 'two' => 'zwei'})
DICTIONARY.load(:ja, :hash => {'one' => '一', 'three' => '三'})

describe Ramaze::Helper::Localize do
  behaves_like :mock

  should 'default to a language' do
    get('/').body.should == 'en'
  end

  should 'override language by ?lang' do
    get('/', :lang => :de).body.should == 'de'
  end

  should 'override language by cookie' do
    get('/', {}, :cookie => 'lang=ja').body.should == 'ja'
  end

  should 'not fail if language is invalid' do
    get('/', :lang => :foobar).body.should == 'foobar'
  end

  should 'use dictionary to translate' do
    get('/translate/one').body.should == 'one'
    get('/translate/one', :lang => :en).body.should == 'one'
    get('/translate/one', :lang => :ja).body.should == '一'
    get('/translate/one', :lang => :de).body.should == 'eins'
  end

  it "falls back to default language if string wasn't found in dictionary" do
    get('/translate/two', :lang => :ja).body.should == 'two'
    get('/translate/three', :lang => :ja).body.should == '三'
  end
end
