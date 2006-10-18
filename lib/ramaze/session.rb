require 'digest/sha1'
require 'digest/md5'

module Ramaze
  class Session
    attr_accessor :session

    # TODO: introduce some key/value cache...

    def initialize request
      @session_id = parse(request)['_session_id']
    end

    def current
      sessions[@session_id]
    end

    def sessions
      @@sessions ||= Hash.new{|h,k| h[k] = {}}
    end

    def parse request
      cookie = request.http_cookie rescue request.http_set_cookie rescue ''
      cookie.split('; ').inject({}) do |s,v| 
        key, value = v.split('=')
        s.merge key.strip => value
      end
    rescue
      Logger.error $!
      {'_session_id' => hash}
    end

    def method_missing meth, *args, &block
      current.send(meth, *args, &block)
    end

    def inspect
      tmp = current.clone
      tmp.delete '_session_id'
      tmp.inspect
    end

    def export
      # do not use #{} here, that would evaluate the id, which is dangerous
      # since given by the user ;)
      "_session_id=" + @session_id
    end

    def hash
      hash = []
      hash << rand * rand ** rand / rand
      hash << Time.now.hash
      hash << 'salt_n_pepper'
      Digest::MD5.hexdigest(hash.join(rand.to_s))
    end
  end
end
