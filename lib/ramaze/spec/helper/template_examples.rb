module Ramaze
  module Spec
    module Examples
      module Templates
        def self.tests( describe, spec_engine )

            describe.behaves_like :mock

            describe.it '/' do
              get('/').body.strip.should =~
                %r{<a href\s*=\s*"/">Home</a> \| <a href\s*=\s*"/internal">internal</a> \| <a href\s*=\s*"/external">external</a>}
            end

            %w[/internal /external].each do |url|
              describe.it url do
                html = get(url).body
                html.should.not == nil
                html.should =~ %r{<title>Template::#{spec_engine} (internal|external)</title>}
                html.should =~ %r{<h1>The (internal|external) Template for #{spec_engine}</h1>}
              end

          end

        end

      end
    end
  end
end
Ramaze.options.views = '../../../examples/templates/view'
