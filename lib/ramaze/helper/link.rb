#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'innate/helper/link'

module Ramaze
  module Helper
    # NOTE: The A/R/Rs methods have been deprecated.
    module Link
      include Innate::Helper::Link

      def self.included(into)
        into.extend(self)
      end

      # @return [String]
      # @see Innate::Helper#anchor
      def A(*args)
        Ramaze.deprecated('Ramaze::Helper::Link#A', 'Ramaze::Helper::Link#a')
        a(*args)
      end

      # @return [String]
      # @see Innate::Helper#route
      def R(arg, *args)
        Ramaze.deprecated('Ramaze::Helper::Link#R', 'Ramaze::Helper::Link#r')
        (arg < Controller ? arg.r(*args) : r(arg, *args)).to_s
      end

      # @return [String]
      # @see Innate::Helper#route
      def Rs(*args)
        Ramaze.deprecated('Ramaze::Helper::Link#Rs', 'Ramaze::Helper::Link#r')
        r(*args).to_s
      end

      # Give it a path with character to split at and one to join the crumbs with.
      # It will generate a list of links that act as pointers to previous pages on
      # this path.
      #
      # Example:
      #   breadcrumbs('/path/to/somewhere')
      #
      #   # results in this, newlines added for readability:
      #
      #   <a href="/path">path</a>/
      #   <a href="/path/to">to</a>/
      #   <a href="/path/to/somewhere">somewhere</a>
      #
      # Optionally a href prefix can be specified which generate link
      # names a above, but with the prefix prepended to the href path.
      #
      # Example:
      #   breadcrumbs('/path/to/somewhere', '/', '/', '/mycontroller/action')
      #
      #   # results in this, newlines added for readability:
      #
      #   <a href="/mycontroller/action/path">path</a>/
      #   <a href="/mycontroller/action/path/to">to</a>/
      #   <a href="/mycontroller/action/path/to/somewhere">somewhere</a>
      #
      # @return [String]
      def breadcrumbs(path, split = '/', join = '/', href_prefix = '')
        atoms = path.split(split).reject{|a| a.empty?}
        crumbs = atoms.inject([]){|s,v| s << [s.last,v]}
        bread = crumbs.map do |a|
          href_path = href_prefix + a*'/'
          a(a[-1], href_path)
        end
        bread.join(join)
      end
    end
  end
end
