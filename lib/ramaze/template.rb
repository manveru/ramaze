#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'

module Ramaze::Template
  %w[ Amrita2 Erubis Ezamar Haml Liquid Markaby ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end

  class Template
    include Ramaze::Helper

    class << self
      def reaction_or_file reaction, file
        if file
          File.read(file)
        elsif reaction.respond_to? :to_str
          reaction
        end
      end
    end
  end
end
