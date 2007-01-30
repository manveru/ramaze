#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

begin
  require 'coderay'
rescue LoadError => ex
end

module Ramaze
  module Error
    class NoAction < StandardError; end
    class NoController < StandardError; end
    class WrongParameterCount < StandardError; end
    class Template < StandardError; end
  end
end
