module Ramaze
  module Helper
    module Gravatar
      def gravatar(email, size = 32, fallback_path = "/images/gravatar_default.jpg")
        emailhash = Digest::MD5.hexdigest(email)

        fallback = request.domain
        fallback.path = fallback_path
        default = CGI.escape(fallback.to_s)

        return "http://www.gravatar.com/avatar.php?gravatar_id=#{emailhash}&default=#{default}&size=#{size}"
      end
    end
  end
end
