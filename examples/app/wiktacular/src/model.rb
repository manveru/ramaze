require 'fileutils'
require 'cgi'

class WikiEntry
  ENTRIES_DIR = __DIR__('../mkd')

  class << self
    def [](name)
      if File.exist?(File.join(ENTRIES_DIR, File.basename(File.expand_path(name))))
        new(name)
      end
    end

    def titles
      Dir[File.join(ENTRIES_DIR,'*')].entries
    end
  end

  include Ramaze::Helper::CGI

  attr_reader :history, :current, :name

  def initialize(name)
    # avoid tampering with the path
    @name = File.basename(File.expand_path(name))
    update
  end

  def update
    @current = "#{base}/current.mkd"
    @history = Dir["#{base}/*_*.mkd"]
  end

  def save(newtext)
    FileUtils.mkdir_p(base)

    if content != newtext
      history_name = "#{base}/#{timestamp}.mkd"
      FileUtils.mv(@current, history_name) if exists?
      File.open(@current, "w+"){|fp| fp.print(newtext) }
    end
  end

  def rename to
    FileUtils.mv(base, "mkd/#{to}")
  end

  def delete
    FileUtils.rm_rf(base) if exists?
  end

  def revert
    return if not exists? or @history.empty?
    FileUtils.mv(@current, @current + ".bak")
    FileUtils.mv(@history.last, @current) unless @history.empty?
    update
  end

  def unrevert
    bakfile = @current + '.bak'
    return unless File.exists?(bakfile)
    FileUtils.mv(bakfile, @current)
    update
  end

  def exists?
    File.exists?(@current)
  end

  def base
    File.join(ENTRIES_DIR, @name)
  end

  def route
    MainController.route(:index, name)
  end

  def content
    CGI.unescapeHTML(File.read(@current)) if exists?
  end

  def timestamp
    Time.now.strftime("%Y-%m-%d_%H-%M-%S")
  end

  def escape_path(path)
    File.basename(File.expand_path(path))
  end
end

class EntryView
  class << self
    def render content
      mkd2html(content || "No Entry")
    end

    def mkd2html(text)
      html = BlueCloth.new(text).to_html

      html.gsub!(/\[\[(.*?)\]\]/) do
        name = $1

        if entry = WikiEntry[name]
          exists = 'exists'
          route = entry.route
        else
          exists = 'nonexists'
          route = MainController.route(:index, name)
        end

        title = Rack::Utils.escape_html(name)
        "<a href='#{route}' class='#{exists}'>#{title}</a>"
      end

      html
    end
  end
end
