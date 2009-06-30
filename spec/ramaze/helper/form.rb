#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)

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

  def hidden
    form_hidden(:secret, request[:secret])
  end

  def select_array
    languages = %w[ English German Japanese ]
    form_select('Languages', :languages, languages)
  end

  def select_array_size
    languages = %w[ English German Japanese ]
    form_select('Languages', :languages, languages, :size => 5)
  end

  def select_array_multiple
    languages = %w[ English German Japanese ]
    form_select('Languages', :languages, languages, :multiple => 1)
  end

  def select_array_selected
    languages = %w[ English German Japanese ]
    form_select('Languages', :languages, languages, :selected => 'German')
  end

  def select_hash
    languages = {'English' => 'en', 'German' => 'de', 'Japanese' => 'ja'}
    form_select('Languages', :languages, languages)
  end
end

describe Ramaze::Helper::Form do
  behaves_like :rack_test

  it 'provides empty text input' do
    got = get('/text')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-username'}
    label.inner_text.should == 'Username:'

    input.attributes.should == {
      'id' => 'form-username',
      'type' => 'text',
      'name' => 'username',
      'value' => '',
      'tabindex' => '1'}
  end

  it 'provides filled text input' do
    got = get('/text?username=manveru')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-username'}
    label.inner_text.should == 'Username:'

    input.attributes.should == {
      'id' => 'form-username',
      'type' => 'text',
      'name' => 'username',
      'value' => 'manveru',
      'tabindex' => '1'}
  end

  it 'provides unchecked checkbox input' do
    got = get('/checkbox')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-admin'}
    label.inner_text.should == 'Administrator:'

    input.attributes.should == {
      'id' => 'form-admin',
      'type' => 'checkbox',
      'name' => 'admin',
      'tabindex' => '1'}
  end

  it 'provides checked checkbox input' do
    got = get('/checkbox?admin=true')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-admin'}
    label.inner_text.should == 'Administrator:'

    input.attributes.should == {
      'id' => 'form-admin',
      'type' => 'checkbox',
      'name' => 'admin',
      'checked' => 'checked',
      'tabindex' => '1'}
  end

  it 'provides password input' do
    got = get('/password')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-password'}
    label.inner_text.should == 'Password:'

    input.attributes.should == {
      'id' => 'form-password',
      'type' => 'password',
      'name' => 'password',
      'tabindex' => '1'}
  end

  it 'provides empty textarea' do
    got = get('/textarea')

    doc = Hpricot(got.body)
    label, textarea = doc.at(:label), doc.at(:textarea)

    label.attributes.should == {'for' => 'form-text'}
    label.inner_text.should == 'Text:'

    textarea.inner_text.should == ''
    textarea.attributes.should == {
      'id' => 'form-text',
      'name' => 'text',
      'tabindex' => '1'}
  end

  it 'provides filled textarea' do
    got = get('/textarea?text=foobar')

    doc = Hpricot(got.body)
    label, textarea = doc.at(:label), doc.at(:textarea)

    label.attributes.should == {'for' => 'form-text'}
    label.inner_text.should == 'Text:'

    textarea.inner_text.should == 'foobar'
    textarea.attributes.should == {
      'id' => 'form-text',
      'name' => 'text',
      'tabindex' => '1'}
  end

  it 'provides file upload input' do
    got = get('/file')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.attributes.should == {'for' => 'form-file'}
    label.inner_text.should == 'File:'

    input.inner_text.should == ''
    input.attributes.should == {
      'id' => 'form-file',
      'name' => 'file',
      'tabindex' => '1',
      'type' => 'file'}
  end

  it 'provides empty hidden input' do
    got = get('/hidden')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.should.be.nil

    input.inner_text.should == ''
    input.attributes.should == {
      'name' => 'secret',
      'type' => 'hidden',
      'value' => ''}
  end

  it 'provides filled hidden input' do
    got = get('/hidden?secret=fish')

    doc = Hpricot(got.body)
    label, input = doc.at(:label), doc.at(:input)

    label.should.be.nil

    input.inner_text.should == ''
    input.attributes.should == {
      'name' => 'secret',
      'type' => 'hidden',
      'value' => 'fish'}
  end

  it 'provides array select' do
    got = get('/select_array')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'name'     => 'languages',
      'size'     => '1',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.
      should == [['English',  {'value' => 'English'}],
                 ['German',   {'value' => 'German'}],
                 ['Japanese', {'value' => 'Japanese'}]]
  end

  it 'provides sized array select' do
    got = get('/select_array_size')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'name'     => 'languages',
      'size'     => '5',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.
      should == [['English',  {'value' => 'English'}],
                 ['German',   {'value' => 'German'}],
                 ['Japanese', {'value' => 'Japanese'}]]
  end

  it 'provides multiple array select' do
    got = get('/select_array_multiple')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'multiple' => 'multiple',
      'name'     => 'languages',
      'size'     => '1',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.
      should == [['English',  {'value' => 'English'}],
                 ['German',   {'value' => 'German'}],
                 ['Japanese', {'value' => 'Japanese'}]]
  end

  it 'provides preselected array select' do
    got = get('/select_array_selected')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'name'     => 'languages',
      'size'     => '1',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.
      should == [['English',  {'value' => 'English'}],
                 ['German',   {'value' => 'German', 'selected' => 'selected'}],
                 ['Japanese', {'value' => 'Japanese'}]]
  end

  it 'provides hash select' do
    got = get('/select_hash')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'name'     => 'languages',
      'size'     => '1',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.sort.
      should == [['English',  {'value' => 'en'}],
                 ['German',   {'value' => 'de'}],
                 ['Japanese', {'value' => 'ja'}]]
  end

  it 'provides hash select' do
    got = get('/select_hash')
    doc = Hpricot(got.body)

    label, select = doc.at(:label), doc.at(:select)

    label.attributes.should == {'for' => 'form-languages'}
    label.inner_text.should == 'Languages:'

    select.attributes.should == {
      'id'       => 'form-languages',
      'name'     => 'languages',
      'size'     => '1',
      'tabindex' => '1'}

    options = select/:option
    options.map{|o| [o.inner_text, o.attributes] }.sort.
      should == [['English',  {'value' => 'en'}],
                 ['German',   {'value' => 'de'}],
                 ['Japanese', {'value' => 'ja'}]]
  end
end
