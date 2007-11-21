# Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Thread
  # Copy following:
  #   :action, :response, :request, :session,
  #   :task, :adapter, :controller, :exception

  def self.into *args
    Thread.new(Thread.current, *args) do |thread, *args|
      thread.keys.each do |k|
        Thread.current[k] = thread[k] unless k.to_s =~ /^__/
      end

      yield *args
    end
  end
end
