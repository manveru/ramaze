module Ramaze

  # This is a container module for wrappers of templating engines and handles
  # lazy requiring of needed engines.

  module View
    extend Innate::View

    ENGINE = {}
    TEMP = {}

    # Combine Kernel#autoload and Ramaze::View::register

    def auto_register(name, *exts)
      autoload(name, "ramaze/view/#{name}".downcase)
      register("Ramaze::View::#{name}", *exts)
    end

    auto_register :Builder, :builder
    auto_register :Haml,    :haml
    auto_register :Maruku,  :mkd, :md
    auto_register :Nagoro,  :xhtml
    auto_register :Sass,    :sass
    auto_register :Tenjin,  :rbhtml
  end
end
