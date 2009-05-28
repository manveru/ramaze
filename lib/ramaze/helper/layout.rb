module Ramaze
  module Helper

    # Provides wrapper methods for a higher-level approach than the core layout
    # method.
    module Layout
      def self.included(into)
        into.extend SingletonMethods
      end

      module SingletonMethods
        def set_layout(hash_or_the_layout)
          if hash_or_the_layout.respond_to?(:to_hash)
            f = hash_or_the_layout.first
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

        def set_layout_except(hash_or_the_layout)
          if hash_or_the_layout.respond_to?(:to_hash)
            f = hash_or_the_layout.to_hash.first
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
