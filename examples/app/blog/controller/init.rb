module Blog
  class Controller < Ramaze::Controller
    engine :Nagoro
    layout(:default){|path, wish| wish !~ /rss|atom/ }
    map_layouts '/'
    trait :app => :blog
    helper :form, :auth, :formatting

    trait :auth_table => lambda{
      password = Digest::SHA1.hexdigest(Blog.options.admin.password)
      {Blog.options.admin.name => password}
    }

    private

    def author_url
      Blog.options.author.url || request.domain(Main.r('/'))
    end

    def sidebar
      out = Ramaze::Gestalt.new

      Blog.options.sidebar.elements.each do |element|
        name, title, *contents = __send__("sidebar_#{element}")

        out.ul(:class => name) do
          out.li(:class => :title){ title }
          contents.flatten.each do |content|
            out.li{ content.to_s }
          end
        end
      end

      out.to_s
    end

    def sidebar_bio
      return :bio, 'About me', Blog.options.sidebar.bio.text.to_s
    end

    def sidebar_admin
      if logged_in?
        links =  [ a('New entry', Entries.r(:new)),
                   a('Logout', Main.r(:logout))   ]
        return :actions, 'Administration', links
      else
        return :login, 'Login', <<FORM.strip
<form method="post" action="#{r :login}">
  #{form_text 'Username', :username}
  #{form_password 'Password', :password}
  #{form_submit 'Login'}
</form>
FORM
      end
    end

    def sidebar_history
      limit = 4; Blog.options.sidebar.history.size
      entries = Entry.select(:id, :title).order(:published.desc).limit(limit)

      return :history, 'History',
        entries.map{|e| a(e.title, e.href) }
    end

    # Don't rel="tag" them, this is bad practice according to microformats
    #
    # The query makes sure that we only select tags that have entries
    # associated with them.
    def sidebar_tagcloud
      tags = Tag.filter(:id => EntriesTags.select(:tag_id)).select(:name).map(:name)
      cloud = []

      tagcloud(tags, 0.8, 2.0).each do |tag, weight|
        style = "font-size: %0.2fem" % weight
        cloud << "<a href='#{Tags.r(tag)}' style='#{style}'>#{h(tag)}</a>"
      end

      return :tagcloud, 'Tags', cloud.sort.join("\n")
    end
  end
end

require 'controller/main'
require 'controller/entry'
require 'controller/tag'
require 'controller/comment'
