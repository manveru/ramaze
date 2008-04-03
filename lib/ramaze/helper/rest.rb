module Ramaze
  module Helper
    module REST
      def self.included(klass)
        klass.class_eval do
          trait :REST => {
            'GET' => [], 'PUT' => [],
            'POST' => [], 'DELETE' => [],
            :any => [],
          }
          extend Indicate

          def self.method_added(name)
            name = name.to_s
            active = trait[:REST][:active] ||= :any
            trait[:REST][active] << name
          end
        end
      end

      module Indicate
        def on(http_method)
          hm = http_method.to_s.upcase
          trait[:REST][hm] = []
          trait[:REST][:active] = hm
        end

        def on_get; on('GET') end
        def on_put; on('PUT') end
        def on_post; on('POST') end
        def on_delete; on('DELETE') end
        def on_any; on(:any) end
      end
    end
  end
end

# POST /foo/bar
# methods_on_post[/foo/bar]
