module Ramaze
  class Current < Innate::Current
    def setup(env, request = Request, response = Response, session = Session)
      super
    end
  end
end
