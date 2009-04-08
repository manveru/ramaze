begin
  require 'securerandom' # Ruby >= 1.8.7
rescue LoadError
  require 'uuidtools'
end

require 'digest/md5'

module Ramaze
  module Helper
    # Authorization using HTTP Digest.
    #
    # For custom authorization failure handling add an {httpdigest_failure}
    # method in your controller.
    module HttpDigest

      SESSION_NONCE = 'httpdigest_authentication_nonce'
      SESSION_OPAQUE = 'httpdigest_authentication_opaque'
      DIGEST_HEADER = %|Digest realm="%s", qop="auth,auth-int", nonce="%s", opaque="%s"|

      # Delete the nonce and opaque from session to log out.
      def httpdigest_logout
        session.delete(SESSION_NONCE)
        session.delete(SESSION_OPAQUE)
      end

      def httpdigest_uuid
        ::SecureRandom.hex(32)
      end

      # Set the WWW-Authenticate header and store relevant data in the session.
      #
      # @param [String] uid
      # @param [String] realm
      def httpdigest_headers(uid, realm)
        nonce = session[SESSION_NONCE] = httpdigest_uuid
        opaque = session[SESSION_OPAQUE][realm][uid] = httpdigest_uuid
        response['WWW-Authenticate'] = DIGEST_HEADER % [realm, nonce, opaque]
      end

      def httpdigest_failure
        respond 'Unauthorized', 401
      end

      def httpdigest_http_authorization(uid, realm)
        http_authorization = request.env['HTTP_AUTHORIZATION']
        return http_authorization if http_authorization

        httpdigest_headers(uid, realm)
        httpdigest_failure
      end

      def httpdigest_lookup(username, realm)
        if block_given?
          yield(username)
        elsif respond_to?(:httpdigest_lookup_password)
          httpdigest_lookup_password(username)
        elsif respond_to?(:httpdigest_lookup_plaintext_password)
          plain = httpdigest_lookup_plaintext_password(username)
          Digest::MD5.hexdigest([username, realm, plain].join(':'))
        else
          raise "No password lookup handler found"
        end
      end

      def httpdigest(uid, realm, &block)
        session[SESSION_OPAQUE] ||= {}
        session[SESSION_OPAQUE][realm] ||= {}

        http_authorization = httpdigest_http_authorization(uid, realm)

        httpdigest_failure unless session_nonce = session[SESSION_NONCE]
        httpdigest_failure unless session_opaque = session[SESSION_OPAQUE][realm][uid]

        auth_type, auth_raw = http_authorization.split(' ', 2)
        httpdigest_failure unless auth_type == 'Digest'

        authorization = Rack::Auth::Digest::Params.parse(auth_raw)

        digest_response, username, nonce, nc, cnonce, qop, opaque =
          authorization.values_at(*%w[response username nonce nc cnonce qop opaque])

        httpdigest_failure unless nonce == session_nonce and opaque == session_opaque

        ha1 = httpdigest_lookup(username, realm, &block)
        a2 = [request.request_method,request.request_uri]
        a2 << Digest::MD5.hexdigest(request.body.read) if qop == "auth-int"
        ha2 = Digest::MD5.hexdigest( a2.join(':') )
        md5 = Digest::MD5.hexdigest([ha1, nonce, nc, cnonce, qop, ha2].join(':'))

        httpdigest_failure unless digest_response == md5

        return username
      end
    end
  end
end
