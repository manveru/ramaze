class PageController < Ramaze::Controller
  map '/page'

  def create
    redirect_referrer unless request.post?
    if text = request[:text]
      page = Page.create :text => text
      redirect page.url
    end
  end
end
