require File.expand_path('../../../../lib/ramaze/helper/blue_form', __FILE__)

require 'bacon'
Bacon.summary_at_exit

describe BF = Ramaze::Helper::BlueForm do
  extend BF

  def tidy(html)
    require 'open3'
    Open3.popen3('tidy -i'){|sin, sout, serr|
      sin.print(html)
      sin.close
      sout.read[/<body>(.+)<\/body>/m, 1]
    }
  end

  # very strange comparision, sort all characters and compare, so we don't have
  # order issues.
  def assert(expected, output)
    left = expected.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    right = output.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    left.scan(/./).sort.should == right.scan(/./).sort
#
#     unless left == right
#       puts "", "Expected:"
#       puts left
#       puts tidy(left)
#       puts "", "Got:"
#       puts right
#       puts tidy(right)
#       puts
#     end
#     left.should == right
  end

  it 'makes form with method' do
    out = form(:method => :post)
    assert(<<-FORM, out)
<form method="post"></form>
    FORM
  end

  it 'makes form with method and action' do
    out = form(:method => :post, :action => '/')
    assert(<<-FORM, out)
<form method="post" action="/"></form>
    FORM
  end

  it 'makes form with method, action, and name' do
    out = form(:method => :post, :action => '/', :name => :spec)
    assert(<<-FORM, out)
    <form method="post" action="/" name="spec">
    </form>
    FORM
  end

  it 'makes form with class and id' do
    out = form(:class => :foo, :id => :bar)
    assert(<<-FORM, out)
    <form class="foo" id="bar">
    </form>
    FORM
  end

  it 'makes form with legend' do
    out = form(:method => :get){|f|
      f.legend('The Form')
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <legend>The Form</legend>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_text(label, name, value)' do
    out = form(:method => :get){|f|
      f.input_text 'Username', :username, 'mrfoo'
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-username">Username</label>
      <input type="text" name="username" class="text" id="form-username" value="mrfoo" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_text(label, name)' do
    out = form(:method => :get){|f|
      f.input_text 'Username', :username
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-username">Username</label>
      <input type="text" name="username" class="text" id="form-username" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_text(label, name, value, hash)' do
    out = form(:method => :get){|f|
      f.input_text 'Username', :username, nil, :size => 10
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-username">Username</label>
      <input size="10" type="text" name="username" class="text" id="form-username" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_password(label, name)' do
    out = form(:method => :get){|f|
      f.input_password 'Password', :password
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-password">Password</label>
      <input type="password" name="password" class="text" id="form-password" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_submit()' do
    out = form(:method => :get){|f|
      f.input_submit
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <input type="submit" class="button submit" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_submit(value)' do
    out = form(:method => :get){|f|
      f.input_submit 'Send'
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <input type="submit" class="button submit" value="Send" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_checkbox(label, name)' do
    out = form(:method => :get){|f|
      f.input_checkbox 'Assigned', :assigned
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-assigned">Assigned</label>
      <input type="checkbox" name="assigned" class="checkbox" id="form-assigned" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_checkbox(label, name, checked = false)' do
    out = form(:method => :get){|f|
      f.input_checkbox 'Assigned', :assigned, false
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-assigned">Assigned</label>
      <input type="checkbox" name="assigned" class="checkbox" id="form-assigned" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_checkbox(label, name, checked = true)' do
    out = form(:method => :get){|f|
      f.input_checkbox 'Assigned', :assigned, true
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-assigned">Assigned</label>
      <input type="checkbox" name="assigned" class="checkbox" id="form-assigned" checked="checked" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_checkbox(label, name, checked = nil)' do
    out = form(:method => :get){|f|
      f.input_checkbox 'Assigned', :assigned, nil
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-assigned">Assigned</label>
      <input type="checkbox" name="assigned" class="checkbox" id="form-assigned" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with textarea(label, name)' do
    out = form(:method => :get){|f|
      f.textarea 'Message', :message
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-message">Message</label>
      <textarea name="message" id="form-message"></textarea>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with textarea(label, name, value)' do
    out = form(:method => :get){|f|
      f.textarea 'Message', :message, 'stuff'
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-message">Message</label>
      <textarea name="message" id="form-message">stuff</textarea>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_file(label, name)' do
    out = form(:method => :get){|f|
      f.input_file 'Avatar', :avatar
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-avatar">Avatar</label>
      <input type="file" name="avatar" class="file" id="form-avatar" />
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_hidden(name)' do
    out = form(:method => :get){|f|
      f.input_hidden :post_id
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <input type="hidden" name="post_id" />
  </fieldset>
</form>
    FORM
  end

  it 'makes form with input_hidden(name, value)' do
    out = form(:method => :get){|f|
      f.input_hidden :post_id, 15
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <input type="hidden" name="post_id" value="15" />
  </fieldset>
</form>
    FORM
  end

  servers_hash = {
    :webrick => 'WEBrick',
    :mongrel => 'Mongrel',
    :thin => 'Thin',
  }

  it 'makes form with select(label, name, values) from hash' do
    out = form(:method => :get){|f|
      f.select 'Server', :server, servers_hash
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-server">Server</label>
      <select id="form-server" size="1" name="server">
        <option value="webrick">WEBrick</option>
        <option value="mongrel">Mongrel</option>
        <option value="thin">Thin</option>
      </select>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with select(label, name, values) with selection from hash' do
    out = form(:method => :get){|f|
      f.select 'Server', :server, servers_hash, :selected => :mongrel
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-server">Server</label>
      <select id="form-server" size="1" name="server">
        <option value="webrick">WEBrick</option>
        <option value="mongrel" selected="selected">Mongrel</option>
        <option value="thin">Thin</option>
      </select>
    </p>
  </fieldset>
</form>
    FORM
  end

  servers_array = %w[ WEBrick Mongrel Thin]

  it 'makes form with select(label, name, values) from array' do
    out = form(:method => :get){|f|
      f.select 'Server', :server, servers_array
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-server">Server</label>
      <select id="form-server" size="1" name="server">
        <option value="WEBrick">WEBrick</option>
        <option value="Mongrel">Mongrel</option>
        <option value="Thin">Thin</option>
      </select>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with select(label, name, values) with selection from array' do
    out = form(:method => :get){|f|
      f.select 'Server', :server, servers_array, :selected => 'Mongrel'
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-server">Server</label>
      <select id="form-server" size="1" name="server">
        <option value="WEBrick">WEBrick</option>
        <option value="Mongrel" selected="selected">Mongrel</option>
        <option value="Thin">Thin</option>
      </select>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'makes form with radio(label, name, values) with selection from array' do
    out = form(:method => :get){|f|
      f.radio 'Server', :server, servers_array, :checked => 'Mongrel'
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-server-0"><input type="radio" value="WEBrick" id="form-server-0" name="server" />WEBrick</label>
      <label for="form-server-1"><input type="radio" value="Mongrel" id="form-server-1" name="server" checked="checked" />Mongrel</label>
      <label for="form-server-2"><input type="radio" value="Thin"    id="form-server-2" name="server" />Thin</label>
    </p>
  </fieldset>
</form>
    FORM
  end

  it 'inserts error messages' do
    form_error :username, 'May not be empty'
    out = form(:method => :get){|f|
      f.input_text 'Username', :username
    }
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <p>
      <label for="form-username">Username <span class="error">May not be empty</span></label>
      <input type="text" name="username" class="text" id="form-username" />
    </p>
  </fieldset>
</form>
    FORM
  end
end
