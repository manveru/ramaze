module Ramaze
  module Helper

    # This helper provides a convenience wrapper for handling authentication
    # and persistence of users.
    # It will wrap and cache the value returned by the callback or model during
    # one request/response cycle.
    # On every request it checks authentication again and retrieves the model.
    #
    # Incomplete example:
    #
    # class MainController < Ramaze::Controller
    #   trait :user_callback => lambda{|auth| }
    #
    #   def index
    #     return "Hello #{user.name}" if logged_in?
    #     a('login', :login)
    #   end
    #
    #   def login
    #     user_login if reuqest.post?
    #   end
    # end
    module User
      RAMAZE_HELPER_USER = 'ramaze.helper.user'.freeze

      # Use this method in your application, but do not use it in conditionals
      # as it will never be nil or false.
      #
      # @return [Ramaze::Helper::User::Wrapper] wrapped return value from model or callback
      def user
        env = request.env
        found = env[RAMAZE_HELPER_USER]
        return found if found

        model, callback = ancestral_trait.values_at(:user_model, :user_callback)
        model ||= ::User
        env[RAMAZE_HELPER_USER] = Wrapper.new(model, callback)
      end

      # shortcut for user._login but default argument are request.params
      #
      # @param [Hash] creds the credentials that will be passed to callback or model
      # @return [nil Hash] the given creds are returned on successful login
      # @see Ramaze::Helper::User::Wrapper#_login
      # @author manveru
      def user_login(creds = request.params)
        user._login(creds)
      end

      # shortcut for user._logout
      # @return [nil]
      # @see Ramaze::Helper::User::Wrapper#_logout
      # @author manveru
      def user_logout
        user._logout
      end

      # @return [true false] whether the user is logged in already.
      # @see Ramaze::Helper::User::Wrapper#_logged_in?
      # @author manveru
      def logged_in?
        user._logged_in?
      end

      # Wrapper for the ever-present "user" in your application.
      # It wraps around an arbitrary instance and worries about authentication
      # and storing information about the user in the session.
      #
      # In order to not interfere with the wrapped instance/model we start our
      # methods with an underscore.
      #
      # Patches and suggestions are highly appreciated.
      class Wrapper < BlankSlate
        attr_accessor :_model, :_callback, :_user

        def initialize(model, callback)
          @_model, @_callback = model, callback
          @_user = nil
          _login
        end

        # @param [Hash] creds this hash will be stored in the session on successful login
        # @return [Ramaze::Helper::User::Wrapper] wrapped return value from
        #                                         model or callback
        # @see Ramaze::Helper::User#user_login
        # @autor manveru
        def _login(creds = _persistence)
          if @_user = _would_login?(creds)
            self._persistence = creds
          end
        end

        # The callback should return an instance of the user, otherwise it
        # should answer with nil.
        #
        # This will not actually login, just check whether the credentials
        # would result in a user.
        def _would_login?(creds)
          if c = @_callback
            c.call(creds)
          elsif _model.respond_to?(:authenticate)
            _model.authenticate(creds)
          else
            Log.warn("Helper::User has no callback and there is no %p::authenticate" % _model)
            nil
          end
        end

        # @see Ramaze::Helper::User#user_logout
        # @autor manveru
        def _logout
          _persistence.clear
          Current.request.env['ramaze.helper.user'] = nil
        end

        # @return [true false] whether the current user is logged in.
        # @see Ramaze::Helper::User#logged_in?
        # @autor manveru
        def _logged_in?
          !!_user
        end

        def _persistence=(creds)
          Current.session[:USER] = creds
        end

        def _persistence
          Current.session[:USER] || {}
        end

        # Refer everything not known
        # THINK: This might be quite confusing... should we raise instead?
        def method_missing(meth, *args, &block)
          return unless _user
          _user.send(meth, *args, &block)
        end
      end
    end
  end
end
