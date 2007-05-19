#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'yaml'

module Ramaze
  module Tool
    module MIME

      trait :types => YAML.load_file(BASEDIR/'ramaze'/'tool'/'mime_types.yaml')

      class << self
        def type_for file
          ext = File.extname(file)
          trait[:types][ext].to_s
        end
      end
    end
  end
end
