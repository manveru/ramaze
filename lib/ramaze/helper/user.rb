module Ramaze
  module Helper
    module User
      # Define the :user_model trait
      def self.inherited(klass)
        klass.trait :user_model => ::User
      end

      # yield or instantinate Wrapper for @user_helper
      def user
        if instance_variable_defined?('@user_helper')
          @user_helper
        else
          @user_helper = Wrapper.new ancestral_trait[:user_model]
        end
      end

      # Wrapper for the ever-present "user" in your application.
      # It wraps around an arbitrary instance and worries about authentication
      # and storing information about the user in the session.
      class Wrapper
        thread_accessor :session
        attr_accessor :user

        # new Wrapper, pass it your definition of user.
        def initialize(model)
          raise ArgumentError, "No model defined for Helper::User" unless model
          @model = model
          @user = nil
          login(persist)
        end

        # Do we have a @user yet?
        def logged_in?
          !!@user
        end

        def login?(hash)
          credentials = {}
          hash.each{|k,v| credentials[k.to_sym] = v.to_s }
          @model[credentials]
        end

        def persist
          session[:USER] ||= {}
        end

        def persist=(hash)
          session[:USER] = hash
        end

        def login(hash = Request.current.params)
          return if hash.empty?
          if found = login?(hash)
            @user = found
            self.persist = hash
          end
        end

        # Clear the persistance layer, forgetting all information we have.
        def logout
          persist.clear
        end

        # Refer everything not known
        def method_missing(meth, *args, &block)
          @user.send(meth, *args, &block)
        end
      end
    end
  end
end
