#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # RedirectHelper actually takes advantage of LinkHelper.link_raw to build the links
  # it redirects to.
  # It doesn't do much else than this:
  #     setting a status-code of 303 and a response['Location'] = link
  # returning some nice text for visitors who insist on ignoring those hints :P
  #
  # example of usage:
  #   redirect MainController
  #   redirect MainController, :foo
  #   redirect 'foo/bar'
  #
  # TODO:
  #   - setting custom status-code, it ignores any preset ones at the moment
  #   - maybe some more options, like a delay
  #

  module RedirectHelper

    # Usage:
    #   redirect MainController
    #   redirect MainController, :foo
    #   redirect 'foo/bar'

    def redirect target
      header = {
        'Location' => target
      }.merge(response.header)
      status ||= STATUS_CODE[:see_other]
      body = %{Please follow <a href="#{target}">#{target}</a>!}


      Dispatcher.build_response body, status, header

      throw(:respond, response)
    end

    # redirect to the location the browser says it's coming from.

    def redirect_referer
      redirect request.referer
    end
  end
end
