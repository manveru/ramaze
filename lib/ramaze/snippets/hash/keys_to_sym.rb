#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class Hash

  # convert all keys in the Hash to symbols.

  def keys_to_sym!
    replace keys_to_sym
  end

  # answer with a new Hash with all keys as symbols.

  def keys_to_sym
    inject({}) do |hash, (k,v)|
      hash.merge k.to_sym => v
    end
  end
end
