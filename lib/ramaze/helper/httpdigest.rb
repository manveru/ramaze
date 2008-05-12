module Ramaze
  module Helper
    module HttpDigest

      require 'uuid'
      require 'md5'

      LOOKUP << self

      protected

      def httpdigest uid, realm, &block
        session_opaque = "authentication_digest_opaque_#{uid}"
        session_nonce = "authentication_digest_nonce"

        session[session_opaque] ||= UUID.new

        authorized = false

        if request.env['HTTP_AUTHORIZATION']
          
          authorization = request.env['HTTP_AUTHORIZATION']

          authentication_type = authorization.split[0]

          if authentication_type == 'Digest'

            their_nonce= authorization.gsub(/.* nonce="(.*?)".*/,"\\1")

            if their_nonce == session[session_nonce]

              username = authorization.gsub(/.* username="(.*?)".*/,"\\1")
              nonceCount = authorization.gsub(/.* nc=([0-9]+).*/,"\\1")
              cnonce= authorization.gsub(/.* cnonce="(.*?)".*/,"\\1")
              #XXX curl sends quotes to qop, firefox does not
              qop = authorization.gsub(/.* qop="?(.*?)"?,.*/,"\\1")

              ha1 = block.call( username )
              ha2 = MD5.new( "#{request.request_method}:#{request.fullpath}" )

              their_response = authorization.gsub(/.*response="([^"]*).*/,"\\1")
              our_response = MD5.new( "#{ha1}:#{session[session_nonce]}:#{nonceCount}:#{cnonce}:#{qop}:#{ha2}" ).to_s;

              authorized = ( their_response == our_response )
            end

          end

        end

        unless authorized
          session[session_nonce] = UUID.new
          response['WWW-Authenticate'] = %|Digest realm="#{realm}",qop="auth,auth-int",nonce="#{session[session_nonce]}",opaque="#{session[session_opaque]}"|
          respond 'Unauthorized', 401
        end

        username
      end
    end
  end
end
