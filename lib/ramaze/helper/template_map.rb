#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module TemplateMap

    def template_map from, to
      (trait[:template_map] ||= {})[from.to_s] = to.to_s
    end

  end
end
