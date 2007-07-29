#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher

    # Generates a directory listing, see Ramaze::Controller::Directory for more
    # information and how to create your own directory listing page
    class Directory
      class << self

        # Entry point from Dispatcher::filter.
        # Just a forwarder to build_listing, automatticly exiting if there is
        # an error (defined by returning false in build_listing)
        def process(path)
          return unless html = build_listing(path)
          Dispatcher.build_response(html, Ramaze::STATUS_CODE['OK'])
        end

        # Makes a request for http://yourserver/dirlist/path and returns the
        # result. Due to this method, you can overwrite the action and create your
        # own page. See Ramaze::Controller::Directory for more.
        def build_listing(path)
          return false unless Global.list_directories
          dir = Global.public_root/path

          if ::File.directory?(dir)
            response = Response.current
            response['Content-Type'] = "text/html"
            Inform.debug("Serving directory listing: #{dir}")
            response.body = Controller.resolve("/dirlist/#{dir}")
          end
        end
      end
    end
  end
end

