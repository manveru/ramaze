#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ezamar
  class RenderPartial

    # Renders <render src="/path" [optional="option", ...]> in place.
    #
    # Other options than `src` will be transformed to session parameters for the
    # rendered action to use.

    def self.transform(template, action, file = __FILE__)
      template.gsub!(/<render (.*?) \/>/) do |m|
        args = Hash[*$1.scan(/(\S+)=["'](.*?)["']/).flatten]
        if src = args.delete('src')
          PartialHelper.render_partial(src, args)
        end
      end

      template
    end

  end
end
