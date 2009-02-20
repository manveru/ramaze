#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # This is a container module for wrappers of templating engines and handles
  # lazy requiring of needed engines.

  module View
    extend Innate::View

    # Combine Kernel#autoload and Innate::View::register

    def self.auto_register(name, *exts)
      autoload(name, "ramaze/view/#{name}".downcase)
      register("Ramaze::View::#{name}", *exts)
    end

    # TODO:
    # * markaby - though we should advertise remarkably instead
    # * XSLT    - this one is just crazy, someone up for the task?

    auto_register :Amrita2,    :amrita, :amr, :a2html
    auto_register :Erubis,     :erubis, :rhtml
    auto_register :Haml,       :haml
    auto_register :Liquid,     :liquid
    auto_register :Maruku,     :mkd, :md
    auto_register :Nagoro,     :xhtml, :nag
    auto_register :RedCloth,   :redcloth
    auto_register :Sass,       :sass
    auto_register :Tenjin,     :rbhtml
    auto_register :Remarkably, :rem
    auto_register :Tagz,       :rb, :tagz
  end
end

module Innate
  module View
    include Ramaze::View
  end
end
