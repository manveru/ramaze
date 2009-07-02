module Ramaze
  module Helper

    # Provides wrapper methods for a higher-level approach than the core layout
    # method.  These are useful for simpler layout needs, particularly:
    #
    # * layout all actions
    # * layout a whitelist of actions
    # * layout all but a blacklist of actions
    #
    # As with the core layout method, the layout rules apply only to the
    # controller on which they are applied.  Furthermore, multiple layout
    # definitions are not combined; only the last definition will be used.
    #
    # This helper is one of the default helpers, so no explicit helper call
    # is necessary before using it in your controllers.
    #
    # Usage:
    #
    #    class MainController < Controller
    #      # Apply the default layout (e.g. ./layout/default.xhtml) to all
    #      # three actions.
    #      set_layout 'default'
    #      def action1; end
    #      def action2; end
    #      def action3; end
    #    end
    #
    #    class MainController < Controller
    #      # These two layout definitions accomplish the same thing.  The
    #      # first uses a whitelist, the second uses a blacklist.
    #      set_layout 'default' => [:laid_out1, :laid_out2]
    #      set_layout_except 'default' => [:not_laid_out1, :not_laid_out2]
    #
    #      def laid_out1; end
    #      def laid_out2; end
    #
    #      def not_laid_out1; end
    #      def not_laid_out2; end
    #    end
    module Layout
      def self.included(into)
        into.extend SingletonMethods
      end

      module SingletonMethods
        # @param [String Hash] Either a layout name, or a single-element Hash
        #   which maps a layout name to an Array containing a whitelist of
        #   action names
        # @see set_layout_except Innate::Node::layout
        # @author Pistos, manveru
        # @example Use a layout named 'default' on all actions of the controller:
        #   set_layout 'default'
        # @example Use a layout named 'default' on just the index and admin actions:
        #   set_layout 'default' => [ :index, :admin ]
        def set_layout(hash_or_the_layout)
          if hash_or_the_layout.respond_to?(:to_hash)
            f = hash_or_the_layout.to_hash.find{|k,v| k && v }
            the_layout = f[0]
            whitelist = f[1].map{|action| action.to_s }
          else
            the_layout = hash_or_the_layout
          end

          layout do |path, wish|
            if whitelist.nil? || whitelist.include?(path.to_s)
              the_layout
            end
          end
        end

        # @param [String Hash] Either a layout name, or a single-element Hash
        #   which maps a layout name to an Array containing a blacklist of
        #   action names
        # @see set_layout Innate::Node::layout
        # @author Pistos, manveru
        # @example Use a layout named 'default' on all actions except the user_data action:
        #   set_layout_except 'default' => [ :user_data ]
        def set_layout_except(hash_or_the_layout)
          if hash_or_the_layout.respond_to?(:to_hash)
            f = hash_or_the_layout.to_hash.find{|k,v| k && v }
            the_layout = f[0]
            blacklist = f[1].map{|action| action.to_s }
          else
            the_layout = hash_or_the_layout
          end

          layout do |path, wish|
            if blacklist.nil? || !blacklist.include?(path.to_s)
              the_layout
            end
          end
        end
      end
    end
  end
end
