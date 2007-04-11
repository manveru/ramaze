#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # This class acts as a object you can pass to any other logger, it's basically
  # just including Inform and making its methods public

  class GlobalInformer
    include Inform

    public :error, :error?, :info, :info?, :debug, :debug?, :warn, :warn?

    # this simply sends the parameters to #debug

    def <<(*str)
      debug(*str)
    end
  end

  # The usual instance of GlobalInformer, for example used for WEBrick

  Informer = GlobalInformer.new

end
