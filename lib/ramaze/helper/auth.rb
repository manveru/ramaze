module Ramaze
  module AuthHelper
    def login
      if pass = request.params['password']
        session[:logged_in] = (pass == 'passwort')
        redirect R(self)
      else
        %{
          <form method="POST" action="#{R(BlogController, :login)}"
            <input type="password" name="password" />
            <input type="submit" />
          </form>
        }
      end
    end

    def logout
      session.clear
      redirect R(self)
    end

    private

    def logged_in?
      redirect R(self) unless check_login
    end

    def check_login
      session[:logged_in]
    end
  end
end
