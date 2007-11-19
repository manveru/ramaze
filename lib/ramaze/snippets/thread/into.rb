# Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Thread
  # Copy following:
  #   :action, :response, :request, :session,
  #   :task, :adapter, :controller, :exception

  def self.into
    Thread.new(Thread.current) do |thread|
      current = Thread.current

      vars = Dir["#{Ramaze::BASEDIR}/**/*.rb"].
        map{|f| File.readlines(f).
          map{|l| l[/Thread\.current\[:([^\]]*)\]/, 1] } }

      vars.flatten.compact.uniq.each do |var|
        var = var.to_sym
        current[var] = thread[var]
      end

      yield
    end
  end
end
