module Ramaze
  module LinkHelper
    def link *to
      hash = to.last.is_a?(Hash) ? to.pop : {}

      to = to.flatten

      to.map! do |t|
        Global.mapping.invert[t] || t
      end

      link = to.join('/').squeeze('/')
      title = link.split('/').last

      if hash[:raw]
        link
      else
        %{<a href="#{link}">#{title}</a>}
      end
    end

    def link_raw *to
      if to.last.is_a?(Hash)
        to.last[:raw] = true
      else
        to << {:raw => true}
      end

      link(*to)
    end
  end
end
