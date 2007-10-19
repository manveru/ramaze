module Ramaze
  module Template

      class None < Template
        def self.transform action
          render_method(action)
        end
      end

  end
end