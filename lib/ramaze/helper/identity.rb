#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'tmpdir'
require 'openid'

module Ramaze

  # This is called Identity to avoid collisions with the original openid.rb

  module IdentityHelper
    def self.included(klass)
      klass.send(:helper, :flash)
    end

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
      session[:openid_entry] = request.referrer

      openid_request = openid_consumer.begin(url)
      case openid_request.status
      when OpenID::FAILURE
        flash[:error] = "OpenID - Unable to find openid server for `#{url}'"

        redirect_referrer
      when OpenID::SUCCESS
        root         = "http://#{request.http_host}/"
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
        session[:openid_identity] = openid_response.identity_url
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

Ramaze::Global.openid_store ||= OpenID::FilesystemStore.new(openid_store_file)
