#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FlashHelper
    private

    def flash
      session[:FLASH] ||= {}

      flash_id = Thread.current.object_id + self.object_id

      session[:FLASH][flash_id] ||= {}
      session[:FLASH].each do |id, value|
        if id != flash_id
          if session[:FLASH][id][:flush]
            session[:FLASH].delete(id)
          else
            session[:FLASH][id][:flush] = true
          end
        end
      end

      current = session[:FLASH][flash_id]
      previous = session[:FLASH].find{|h,k| k[:flush]}.last rescue {}
      session[:FLASH][flash_id] = previous.merge(current)
    end
  end
end
