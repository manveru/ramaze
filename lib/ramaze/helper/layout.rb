module Ramaze
  module Helper

    # Provides wrapper methods for a higher-level approach than the core layout method.

    module Layout

      def self.included(into)
        into.extend self
        into.extend Innate::Traited
      end

      def set_layout(hash_or_the_layout)
        if hash_or_the_layout.respond_to?(:to_hash)
          f = hash_or_the_layout.first
          trait :the_layout => f[0]
          trait :layout_whitelist => f[1].map { |action| action.to_s }
        else
          trait :the_layout => hash_or_the_layout
        end

        layout {|path,wish|
          whitelist = trait[ :layout_whitelist ]
          if whitelist.nil? || whitelist.include?(path.to_s)
            trait[ :the_layout ]
          end
        }
      end

      def set_layout_except(hash_or_the_layout)
        if hash_or_the_layout.respond_to?(:to_hash)
          f = hash_or_the_layout.first
          trait :the_layout => f[0]
          trait :layout_blacklist => f[1].map { |action| action.to_s }
        else
          trait :the_layout => hash_or_the_layout
        end

        layout {|path,wish|
          blacklist = trait[ :layout_blacklist ]
          if blacklist.nil? || ! blacklist.include?(path.to_s)
            trait[ :the_layout ]
          end
        }
      end

    end
  end
end
