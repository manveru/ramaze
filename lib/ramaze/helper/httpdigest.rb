require 'uuid'
require 'md5'

module Ramaze
  module Helper
    module HttpDigest

      private

      def httpdigest uid, realm, &block
        session_opaque = "authentication_digest_opaque_#{uid}"
        session_nonce = "authentication_digest_nonce"

        session[session_opaque] ||= UUID.new

        authorized = false

        if session[session_nonce] and request.env['HTTP_AUTHORIZATION']
          
          auth_split = request.env['HTTP_AUTHORIZATION'].split
          authentication_type = auth_split[0]
          authorization = auth_split[1..-1].join(' ').scan(/((?:"(?:\\.|[^"])+?"|[^",]+)+)(?:,\s*|\Z)/n).collect{|v|v[0]}.inject({}){|r,c|k,*v=c.split('=');r[k]=v.join('=').gsub(/"?(.*?)"?/,'\\1');r}

          if authentication_type == 'Digest'

            if authorization["nonce"] == session[session_nonce]

              ha1 = block.call( authorization["username"] )
              ha2 = MD5.new( "#{request.request_method}:#{request.fullpath}" )

              authorized = ( authorization["response"] == MD5.new( "#{ha1}:#{authorization["nonce"]}:#{authorization["nc"]}:#{authorization["cnonce"]}:#{authorization["qop"]}:#{ha2}" ).to_s )

            end

          end

        end

        unless authorized
          session[session_nonce] = UUID.new
          response['WWW-Authenticate'] = %|Digest realm="#{realm}",qop="auth,auth-int",nonce="#{session[session_nonce]}",opaque="#{session[session_opaque]}"|
          respond 'Unauthorized', 401
        end

        authorization["username"]
      end
    end
  end
end
