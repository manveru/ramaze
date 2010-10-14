module Ramaze
  module Helper

    # Provides shortcuts to the link/script tags.
    module XHTML
      LINK_TAG = '<link href=%p media=%p rel="stylesheet" type="text/css" />'
      SCRIPT_TAG = '<script src=%p type="text/javascript"></script>'

      def css(name, media = 'screen', options = {})
        if media.respond_to?(:keys)
          options = media
          media = 'screen'
        end

        if only = options.delete(:only) and only.to_s == 'ie'
          "<!--[if IE]>#{css(name, media, options)}<![endif]-->"
        else
          if name =~ /^http/
            LINK_TAG % [name, media]
          else
            prefix = options[:prefix] || 'css'
            LINK_TAG % ["#{Ramaze.options.prefix.chomp("/")}/#{prefix}/#{name}.css", media]
          end
        end
      end

      def css_for(*args)
        args.map{|arg| css(*arg) }.join("\n")
      end

      def js(name, options={})
        if name =~ /^http/ # consider it external full url
          SCRIPT_TAG % name
        else
          SCRIPT_TAG % "#{Ramaze.options.prefix.chomp("/")}/#{options[:prefix] || 'js'}/#{name}.js"
        end
      end

      def js_for(*args)
        args.map{|arg| js(*arg) }.join("\n")
      end
    end
  end
end
