#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  unless defined?(Action) # prevent problems for SourceReload

    # The Action holds information that is essential to render the action for a
    # request.

    class Action < Struct.new('Action', :controller, :method, :params, :template, :binding)
      def to_s
        %{#<Action method=#{method.inspect}, params=#{params.inspect} template=#{template.inspect}>}
      end

      # runs all parameters assinged through flatten and CGI.unescape

      def params=(*par)
        self[:params] = par.flatten.map{|pa| CGI.unescape(pa)}
      end
    end
  end
end
