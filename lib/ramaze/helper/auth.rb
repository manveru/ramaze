#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper

    # A simple way to do authentication without a model.
    # Please have a look at the docs of Auth#auth_login.
    #
    # If you want to do authentication with a model see Helper::User instead.
    module Auth
      Helper::LOOKUP << self
      include Ramaze::Traited

      trait :auth_table => {}
      trait :auth_hashify => lambda{|pass| Digest::SHA1.hexdigest(pass) }
      trait :auth_post_only => false

      def self.included(into)
        into.helper(:stack)
      end

      def login
        return auth_template if trait[:auth_post_only] and !request.post?
        @username, password = request[:username, :password]
        answer(request.referer) if auth_login(@username, password)
        return auth_template
      end

      def logout
        auth_logout
        answer(request.referer)
      end

      private

      def login_required
        call(r(:login)) unless logged_in?
      end

      # @return [true false] whether user is logged in right now
      def logged_in?
        !!session[:logged_in]
      end

      # @return
      def auth_login(user, pass)
        return unless user and pass
        return if user.empty? or pass.empty?
        return unless table = ancestral_trait[:auth_table]
        return unless hashify = ancestral_trait[:auth_hashify]

        if table.respond_to?(:to_sym) or table.respond_to?(:to_str)
          table = send(table)
        elsif table.respond_to?(:call)
          table = table.call
        end

        return unless table[user] == hashify.call(pass)

        session[:logged_in] = true
        session[:username] = user
      end

      def auth_logout
        session.delete(:logged_in)
        session.delete(:username)
      end

      # @return [String] template for auth
      def auth_template
        <<-TEMPLATE.strip!
<form method="post" action="#{r(:login)}">
  <ul style="list-style:none;">
    <li>Username: <input type="text" name="username" value="#@username"/></li>
    <li>Password: <input type="password" name="password" /></li>
    <li><input type="submit" /></li>
  </ul>
</form>
        TEMPLATE
      end
    end
  end
end
