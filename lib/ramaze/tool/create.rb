#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'fileutils'
require 'yaml'

module Ramaze
  module Tool
    class Create
      class << self
        def create project
          mkdir project
          FileUtils.cp_r((::Ramaze::BASEDIR / 'proto'), project)
        end
      end
    end
  end
end
