module Ramaze
  module RedirectHelper
    def redirect *target
      target = target.join('/')
      response.head['Location'] = target
      response.code = 303
      %{Please follow <a href="#{target}">#{target}</a>!}
    end
  end
end
