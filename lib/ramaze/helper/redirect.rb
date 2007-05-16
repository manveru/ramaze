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
  #   redirect :index, :status => 309
  #
  # TODO:
  #   - maybe some more options, like a delay
  #

  module RedirectHelper

    private

    # Usage:
    #   redirect R(MainController)
    #   redirect R(MainController, :foo)
    #   redirect 'foo/bar'

    def redirect target, opts = {}
      target = target.to_s
      head = {
        'Location' => target
      }.merge(response.header)

      status = opts[:status] || STATUS_CODE["See Other"]

      body = %{Please follow <a href="#{target}">#{target}</a>!}


      throw(:redirect, :body => body, :status => status, :head => head)
    end

    # redirect to the location the browser says it's coming from.

    def redirect_referer
      redirect request.referer
    end
  end
end
