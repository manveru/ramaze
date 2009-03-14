module Ramaze
  # Serving multiple public directories made easy.
  class Files
    def initialize(*roots)
      @roots = roots.flatten.map{|root| File.expand_path(root.to_s) }
      sync
    end

    def call(env)
      @cascade.call(env)
    end

    def <<(path)
      @roots << File.expand_path(path.to_s)
      @roots.uniq!
      sync
    end

    def sync
      file_apps = @roots.map{|root| Rack::File.new(root) }
      @cascade = Rack::Cascade.new(file_apps)
    end
  end
end
