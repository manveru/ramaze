#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'tmpdir'

require 'openid'

module Ramaze
  module OpenidHelper
    def openid_login_form
      %{
<form method="GET" action="#{R(self, :openid_begin)}">
  Identity URL: <input type="text" name="url" />
  <input type="submit" />
</form>
      }
    end

    def openid_begin
      url = request['url']
      redirect_referrer if url.nil? or url.empty?
      session[:openid_entry] = referrer

      openid_request = openid_consumer.begin(url)
      case openid_request.status
      when OpenID::FAILURE
        flash[:error] = "OpenID - Unable to find openid server for `#{url}'"

        redirect_referrer
      when OpenID::SUCCESS
        host, port   = Ramaze::Global.host, Ramaze::Global.port
        root         = "http://#{host}:#{port}/"
        return_to    = root[0..-2] + R(self, :openid_complete)
        redirect_url = openid_request.redirect_url(root, return_to)

        redirect(redirect_url)
      end
    end

    def openid_complete
      openid_response = openid_consumer.complete(request.params)

      case openid_response.status
      when OpenID::FAILURE
        flash[:error] = 'OpenID - Verification failed.'
      when OpenID::SUCCESS
        flash[:success] = 'OpenID - Verification done.'
      end

      redirect session[:openid_entry]
    end

    private

    def openid_consumer
      OpenID::Consumer.new(session, Ramaze::Global.openid_store)
    end
  end
end

openid_store_file = File.join(Dir.tmpdir, 'openid-store')

Global.openid_store ||= OpenID::FilesystemStore.new(openid_store_file)
