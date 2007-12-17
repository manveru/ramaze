Ramaze::Contrib::Route[%r!^/(\d+)\.(?:te?xt|plain)$!] = '/plain/%d'
Ramaze::Contrib::Route[%r!^/(?:te?xt|plain)/(\d+)$!] = '/plain/%d'
Ramaze::Contrib::Route[%r!^/(\d+)\.(\w+)$!] = '/view/%d/%s'
Ramaze::Contrib::Route[%r!^/(\d+)$!] = '/view/%d/html'
Ramaze::Contrib::Route[%r!^/page/(\d+)$!] = '/%d'
# Ramaze::Contrib::Route[%r!^/list/?(.*)!] = '/%s'

class PasteController < Ramaze::Controller
  map :/
  engine :Ezamar
  helper :formatting, :sequel, :aspect
  layout :layout
  deny_layout :plain, :save_theme

  def index(start = 1)
    ordered = Paste.order(:created.DESC)
    @paginated = ordered.paginate(start.to_i, 10)
    @pager = paginator(@paginated, '/page')
    @pastes = @paginated
    @style = session[ :theme ] || STYLE
  end

  def save
    syntax, text = request[:syntax, :text]

    if request.post? and syntax and text
      paste = Paste.create :syntax => syntax,
        :text => text,
        :created => Time.now
      redirect R(:/, paste.id)
    end

    redirect_referrer
  end

  def copy(id)
    @paste = paste_for(id)
  end

  def view(id, format)
    @paste, @format = paste_for(id), format
    @syntax = @paste.syntax_name
    @style = session[ :theme ] || STYLE
    @formatted = @paste.view(format, @style)

    ordered = Paste.order(:created.DESC)
    @paginated = ordered.paginate(id.to_i, 1)
    @pager = paginator(@paginated, '/')
  end

  # Do not run through templating

  def plain(id)
    paste = paste_for(id)
    response['Content-Type'] = 'text/plain'
    response.body = paste.text
    throw :respond
  end
    
  def save_theme( theme_name )
    session[ :theme ] = theme_name
  end

  private

  def paste_for(id)
    redirect Rs() unless paste = Paste[:id => id.to_i]
    paste
  end
end
