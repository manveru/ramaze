module Ramaze
  def self.contrib(*args)
    Ramaze::Contrib.load *args
  end
  
  module Contrib
    class << self
      def load(*contribs)
        contribs.each do |name|
          require "ramaze/contrib/#{name}"
          const = Ramaze::Contrib.const_get(name.to_s.camel_case)
          Ramaze::Global.contribs << const
          const.startup if const.respond_to?(:startup)
          Inform.debug "Loaded contrib: #{const}"
        end
      end
    end
  end
end
