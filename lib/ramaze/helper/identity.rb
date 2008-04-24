#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'openid'
require 'openid/store/filesystem'
require 'openid/extensions/pape'

module Ramaze

  openid_store_file = ::File.join(Dir.tmpdir, 'openid-store')

  # Constant for storing meta-information persistent
  OpenIDStore = OpenID::Store::Filesystem.new(openid_store_file)

  # This is called Identity to avoid collisions with the original openid.rb
  # It provides a nice and simple way to provide and control access over the
  # OpenID authentication model.

  module Helper
    module Identity
      LOOKUP << self

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

        papereq = OpenID::PAPE::Request.new
        papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
        papereq.max_auth_age = 2*60*60
        openid_request.add_extension(papereq)
        openid_request.return_to_args['did_pape'] = 'y'

        root         = "http://#{request.http_host}/"
        return_to    = request.url.sub(/#{Ramaze::Global.mapping.invert[self.class]}.*$/, Rs(:openid_complete))
          immediate = false
        if openid_request.send_redirect?(root, return_to, immediate)
          redirect_url = openid_request.redirect_url(root, return_to, immediate)
          raw_redirect redirect_url
        else
          # what the hell is @form_text ?
        end

      rescue OpenID::OpenIDError => ex
        flash[:error] = "Discovery failed for #{url}: #{ex}"
        raw_redirect Rs(:/)
      end

      # After having authenticated at the OpenID server browsers are redirected
      # back here and on success we set the session[:openid_identity] and a little
      # default flash message. Then we redirect to wherever session[:openid_entry]
      # points us to, which was set on openid_begin to the referrer
      #
      # TODO:
      #   - maybe using StackHelper, but this is a really minimal overlap?
      def openid_complete
        openid_response = openid_consumer.complete(request.params, request.url)

        case openid_response.status
        when OpenID::Consumer::FAILURE
          flash[:error] = 'OpenID - Verification failed: ' + openid_response.message
        when OpenID::Consumer::SUCCESS
          session[:openid_identity] = openid_response.identity_url
          flash[:success] = 'OpenID - Verification done.'
        end

        session.delete(:_openid_consumer_service)

        raw_redirect session[:openid_entry]
      end

      private

      # Fetch/Create a OpenID::Consumer for current session.
      def openid_consumer
        OpenID::Consumer.new(session, Ramaze::OpenIDStore)
      end
    end
  end
end
