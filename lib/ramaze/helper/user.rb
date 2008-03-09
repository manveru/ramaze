module Ramaze
  module Helper
    module User
      def self.inherited(klass)
        klass.trait :user_model => ::User
      end

      def user
        if instance_variable_defined?('@user_helper')
          @user_helper
        else
          @user_helper = Wrapper.new ancestral_trait[:user_model]
        end
      end

      class Wrapper
        def initialize(session, model)
          @session, @model = session, model
          login(persist)
        end

        def logged_in?
          !!@user
        end

        def login?(hash)
          @model[hash]
        end

        def persist
          @session[:USER] ||= {}
        end

        def persist=(hash)
          @session[:USER] = hash
        end

        def login(hash = Request.current.params)
          if found = login?(hash)
            @user = found
            self.persist = hash
          end
        end

        def method_missing(meth, *args, &block)
          super unless @user.respond_to?(meth)
          @user.send(meth, *args, &block)
        end
      end
    end
  end
end
