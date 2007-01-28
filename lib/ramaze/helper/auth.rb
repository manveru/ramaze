#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze

  # A really, really, totally stupid way to do authentication. It has no
  # roles and only a single password without usernames.
  #
  # It is intended to be a simple way to protect various partions of a page
  # when you start working on it. Also it is a nice way to see how you could
  # implement your own authentication.

  module AuthHelper

    # the default password

    PASSWORD = 'passwort'

    # action for login, takes a password
    # ( ?password=passwort or /login/passwort or via a form )
    # if no password given, shows a simple form to input it.

    def login password = nil
      if pass = password || request.params['password']
        session[:logged_in] = (pass == PASSWORD)
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

    # clear the session and redirect to the index action of the mapping of the
    # current controller.

    def logout
      session.clear
      redirect R(self)
    end

    private

    # redirects if not logged in to index

    def logged_in?
      redirect R(self) unless check_login
    end

    # checks if the user is already logged in.

    def check_login
      session[:logged_in]
    end
  end
end
