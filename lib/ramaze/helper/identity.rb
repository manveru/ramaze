#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'tmpdir'
require 'openid'

module Ramaze

  openid_store_file = File.join(Dir.tmpdir, 'openid-store')

  # Constant for storing meta-information persistent
  OpenIDStore = OpenID::FilesystemStore.new(openid_store_file)

  # This is called Identity to avoid collisions with the original openid.rb
  # It provides a nice and simple way to provide and control access over the
  # OpenID authentication model.

  module IdentityHelper

    # Simple form for use or overwriting.
    # Has to provide the same functionality when overwritten or directly
    # embedded into a page.
    def openid_login_form(caption="login")
      %{
<form method="GET" action="#{Rs(:openid_begin)}">
  Identity URL: <input type="text" name="url" />
  <input type="submit" value="#{caption}"/>
</form>
      }
    end

    # We land here from the openid_login_form and if we can find a matching
    # OpenID server we redirect the user to it, the browser will return to
    # openid_complete when the authentication is complete.
    def openid_begin
      url = request['url']
      redirect_referrer if url.to_s.empty?
      session[:openid_entry] = request.referrer

      openid_request = openid_consumer.begin(url)
      case openid_request.status
      when OpenID::FAILURE
        flash[:error] = "OpenID - Unable to find openid server for `#{url}'"

        redirect_referrer
      when OpenID::SUCCESS
        root         = "http://#{request.http_host}/"
        return_to    = root[0..-2] + Rs(:openid_complete)
        redirect_url = openid_request.redirect_url(root, return_to)

        redirect(redirect_url)
      end
    end

    # After having authenticated at the OpenID server browsers are redirected
    # back here and on success we set the session[:openid_identity] and a little
    # default flash message. Then we redirect to wherever session[:openid_entry]
    # points us to, which was set on openid_begin to the referrer
    #
    # TODO:
    #   - maybe using StackHelper, but this is a really minimal overlap?
    def openid_complete
      openid_response = openid_consumer.complete(request.params)

      case openid_response.status
      when OpenID::FAILURE
        flash[:error] = 'OpenID - Verification failed.'
      when OpenID::SUCCESS
        session[:openid_identity] = openid_response.identity_url
        flash[:success] = 'OpenID - Verification done.'
      end

      session.delete(:_openid_consumer_service)

      redirect session[:openid_entry]
    end

    private

    # Fetch/Create a OpenID::Consumer for current session.
    def openid_consumer
      OpenID::Consumer.new(session, Ramaze::OpenIDStore)
    end
  end
end
