module Ramaze
  module Helper

    # Provides shortcuts to the link/script tags.
    module XHTML
      LINK_TAG = '<link href=%p media=%p rel="stylesheet" type="text/css" />'
      SCRIPT_TAG = '<script src=%p type="text/javascript"></script>'

      def css(name, media = 'screen', options = {})
        if options.empty?
          if name =~ /^http/ # consider it external full url
            LINK_TAG % [name, media]
          else
            LINK_TAG % ["#{Ramaze.options.prefix.chomp("/")}/css/#{name}.css", media]
          end
        elsif options[:only].to_s.downcase == 'ie'
          "<!--[if IE]>#{css(name, media)}<![endif]-->"
        end
      end

      def css_for(*args)
        args.map{|arg| css(*arg) }.join("\n")
      end

      def js(name)
        if name =~ /^http/ # consider it external full url
          SCRIPT_TAG % name
        else
          SCRIPT_TAG % "#{Ramaze.options.prefix.chomp("/")}/js/#{name}.js"
        end
      end

      def js_for(*args)
        args.map{|arg| js(*arg) }.join("\n")
      end
    end
  end
end
