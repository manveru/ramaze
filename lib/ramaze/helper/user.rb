module Ramaze
  module Helper
    # In order to use this helper, define the :user_model trait in your controller
    module User

      # yield or instantinate Wrapper for @user_helper
      def user
        if instance_variable_defined?('@user_helper')
          @user_helper
        else
          @user_helper = Wrapper.new(self, ancestral_trait[:user_model])
        end
      end

      # Wrapper for the ever-present "user" in your application.
      # It wraps around an arbitrary instance and worries about authentication
      # and storing information about the user in the session.
      class Wrapper
        thread_accessor :session
        attr_accessor :user
        attr_reader :model, :controller

        # user.id should bounce to the model
        undef_method(:id) if method_defined?(:id)

        # new Wrapper, pass it your definition of user.
        def initialize(controller, model)
          raise ArgumentError, "No model defined for Helper::User" unless model
          @controller, @model = controller, model
          @user = nil
          login(persist)
        end

        def is?(obj)
          if user and obj.respond_to?(:pk)
            user.class == obj.class and pk == obj.pk
          end
        end

        # Do we have a @user yet?
        def logged_in?
          !!user
        end

        def login?(hash)
          if checker = controller.ancestral_trait[:user_check]
            checker.call(hash)
          else
            model.check(hash)
          end
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
          user.send(meth, *args, &block)
        end

        def owns?(obj)
          if user
            user.owns?(obj)
          else
            false
          end
        end
      end
    end
  end
end
