#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    # The default directory listing page.
    # This is called by Ramaze::Dispatcher::Directory. You can freely override this
    # in MainController to do whatever you want. You can define this to do nothing at all
    # effictivley disabling directory listing but you could just set
    # Global.list_directories to false and not have Ramaze call this action at all
    #
    # This method of calling an action is useful as it allows the user to override
    # the method and create a custom directory listing using their templating engine
    # of choice as well as add extra information as well as create a validating page for
    # the directory listing
    #
    # Custom user implementations _must_ require 1 argument, the directory that has been
    # requested, starting from the public root. Therefore the absolute path would be
    # File.join(Ramaze::Global.public_root, path)
    def dirlist(path)
      subds = Dir[Ramaze::Global.public_root/path]
      response = "<h4>Directory listing for #{path}</h4>"
      subds.each do |item|
        response << "<a href='#{item}'>#{item}</a><br />"
      end
    end
  end
end
