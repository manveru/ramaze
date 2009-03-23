require 'spec/helper'

spec_requires 'hpricot'

class SpecHelperForm < Ramaze::Controller
  map '/'
  helper :form

  def text
    form_text('Username', :username, request[:username])
  end

  def checkbox
    form_checkbox('Administrator', :admin, request[:admin])
  end

  def password
    form_password('Password', :password)
  end

  def textarea
    form_textarea('Text', :text, request[:text])
  end

  def file
    form_file('File', :file)
  end
end

describe Ramaze::Helper::Form do
  behaves_like :mock

  it 'provides empty text input' do
    got = get('/text')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-username'
    label.inner_text.should == 'Username:'

    input[:id].should == 'form-username'
    input[:type].should == 'text'
    input[:name].should == 'username'
    input[:value].should == ''
    input[:checked].should.be.nil
    input[:tabindex].should == '1'
  end

  it 'provides filled text input' do
    got = get('/text?username=manveru')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-username'
    label.inner_text.should == 'Username:'

    input[:id].should == 'form-username'
    input[:type].should == 'text'
    input[:name].should == 'username'
    input[:value].should == 'manveru'
    input[:checked].should.be.nil
    input[:tabindex].should == '1'
  end

  it 'provides unchecked checkbox input' do
    got = get('/checkbox')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-admin'
    label.inner_text.should == 'Administrator:'

    input[:id].should == 'form-admin'
    input[:type].should == 'checkbox'
    input[:name].should == 'admin'
    input[:value].should.be.nil
    input[:checked].should.be.nil
    input[:tabindex].should == '1'
  end

  it 'provides checked checkbox input' do
    got = get('/checkbox?admin=true')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-admin'
    label.inner_text.should == 'Administrator:'

    input[:id].should == 'form-admin'
    input[:type].should == 'checkbox'
    input[:name].should == 'admin'
    input[:value].should.be.nil
    input[:checked].should == 'checked'
    input[:tabindex].should == '1'
  end

  it 'provides password input' do
    got = get('/password')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-password'
    label.inner_text.should == 'Password:'

    input[:id].should == 'form-password'
    input[:type].should == 'password'
    input[:name].should == 'password'
    input[:value].should.be.nil
    input[:checked].should.be.nil
    input[:tabindex].should == '1'
  end

  it 'provides empty textarea' do
    got = get('/textarea')

    doc = Hpricot(got.body)
    label, textarea = doc.at(:label), doc.at(:textarea)

    label[:for].should == 'form-text'
    label.inner_text.should == 'Text:'

    textarea[:id].should == 'form-text'
    textarea[:type].should.be.nil
    textarea[:name].should == 'text'
    textarea[:value].should.be.nil
    textarea[:checked].should.be.nil
    textarea[:tabindex].should == '1'
    textarea.inner_text.should == ''
  end

  it 'provides filled textarea' do
    got = get('/textarea?text=foobar')

    doc = Hpricot(got.body)
    label, textarea = doc.at(:label), doc.at(:textarea)

    label[:for].should == 'form-text'
    label.inner_text.should == 'Text:'

    textarea[:id].should == 'form-text'
    textarea[:type].should.be.nil
    textarea[:name].should == 'text'
    textarea[:value].should.be.nil
    textarea[:checked].should.be.nil
    textarea[:tabindex].should == '1'
    textarea.inner_text.should == 'foobar'
  end

  it 'provides file upload input' do
    got = get('/file')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label[:for].should == 'form-file'
    label.inner_text.should == 'File:'

    input[:id].should == 'form-file'
    input[:type].should == 'file'
    input[:name].should == 'file'
    input[:value].should.be.nil
    input[:checked].should.be.nil
    input[:tabindex].should == '1'
  end
end
