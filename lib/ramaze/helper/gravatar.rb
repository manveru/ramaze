module Ramaze
  module Helper
    module Gravatar
      def gravatar(email, size = 32, fallback_path = "/images/gravatar_default.jpg")
        emailhash = Digest::MD5.hexdigest(email)

        fallback = Request.current.domain
        fallback.path = fallback_path
        default = h(fallback.to_s)

        return "http://www.gravatar.com/avatar.php?gravatar_id=#{emailhash}&default=#{default}&size=#{size}"
      end
    end
  end
end
