module Ramaze
  class MiddlewareCompiler < Innate::MiddlewareCompiler
  end
end

__END__

module Ramaze
  class MiddlewareCompiler < Innate::MiddlewareCompiler
    def ramaze(app = Ramaze::AppMap)
      cascade(
        Ramaze::Files.new(*public_roots(app)),
        Current.new(Route.new(app), Rewrite.new(app)))
    end

    def public_roots(app)
      roots = []

      app.to_hash.values.map do |value|
        options = value.options

        roots = Array[*options.roots]
        publics = Array[*options.public]

        roots.each do |root|
          publics.each do |public|
            roots << ::File.join(root, public)
          end
        end
      end

      roots
    end
  end
end
