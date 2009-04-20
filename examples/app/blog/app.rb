require 'rubygems'
require 'ramaze'

Ramaze.setup :verbose => true do
  gem 'sequel', '2.12.0'
  gem 'maruku', '0.5.9'
end

module Blog
  include Ramaze::Optioned

  options.dsl do
    o 'Title of this blog', :title,
      'Ramaze Blog'

    o 'Subtitle of the blog', :subtitle,
      'manveru.thoughts.to_html'

    sub :author do
      o 'Your name', :name,
        'Michael Fellinger'

      o 'Your email address', :email,
        'm.fellinger@gmail.com'

      o 'URL pointing to you, uses the url of this blog if nil', :url,
        'http://github.com/manveru'
    end

    sub :admin do
      o "Admin username", :name,
        'manveru'

      o "Admin password", :password,
        'letmein'
    end

    sub :sidebar do
      o "Elements to display in the sidebar", :elements,
        [:bio, :tagcloud, :history, :admin]

      sub :bio do
        o 'Describe yourself, you may use html', :text,
          "My name is Forrest, Forrest Gump.<br />
           I enjoy running, chocolate, talking, and Jenny."
      end

      sub :history do
        o "How many past entries should be shown in the history", :size,
          20
      end
    end

    o 'Number of entries shown in entry listings', :list_size,
      10

    o 'How many entries are shown in the feeds', :feed_size,
      100

    o 'Feed UUID', :uuid,
      'ramaze_blog'

    o "Time format used throughout the blog, see `ri Time.strftime`", :time_format,
      '%A, %d.%m.%Y at %R'
  end
end

require 'model/init'
require 'controller/init'
