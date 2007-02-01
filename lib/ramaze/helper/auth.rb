#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha1'

module Ramaze

  # A really, really, totally stupid way to do authentication. It has no
  # roles and only a single password without usernames.
  #
  # It is intended to be a simple way to protect various partions of a page
  # when you start working on it. Also it is a nice way to see how you could
  # implement your own authentication.

  module AuthHelper
    def self.included(klass)
      klass.class_eval do
        helper :aspect, :stack
      end
    end

    # The default Element to use (if any)

    AUTH_ELEMENT = 'Page'

    # action for login, takes a password
    # ( ?password=passwort or /login/passwort or via a form )
    # if no password given, shows a simple form to input it.

    def login
      if check_auth(request['username'], request['password'])
        session[:logged_in] = true
        if inside_stack?
          answer
        else
          redirect R(self)
        end
      else
        %{
          <#{AUTH_ELEMENT}>
            <form method="POST" action="#{R(self, :login)}"
              <ul style="list-style:none;">
                <li>Username: <input type="text" name="username" /></li>
                <li>Password: <input type="password" name="password" /></li>
                <li><input type="submit" /></li>
              </ul>
            </form>
          </#{AUTH_ELEMENT}>
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
      call(R(self, :login)) unless check_login
    end

    # checks if the user is already logged in.

    def check_login
      session[:logged_in]
    end

    def check_auth user, pass
      authtable = {
        'manveru' => '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8'
      }
      password = Digest::SHA1.hexdigest(pass.to_s)
      authtable[user.to_s] == password
    end
  end
end
