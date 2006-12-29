#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'amrita2/template'

module Ramaze::Template
  class Amrita2 < Template

    trait :actionless => true
    trait :template_extensions => %w[html]

    class << self
      include Ramaze::Helper

      def handle_request action, *params

        file = find_template(action)

        raise Ramaze::Error::Template, "No Template found for #{request.request_path}" unless file

        template = ::Amrita2::TemplateFile.new(file)
        out = ''
        template.expand(out, self.new)
        out

      rescue Object => ex
        Inform.error ex
        raise Ramaze::Error::NoAction, "No Action found for #{request.request_path}"
      end
    end
  end
end
