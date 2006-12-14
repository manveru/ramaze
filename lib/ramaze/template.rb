#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'

module Ramaze::Template
  %w[ Ramaze Amrita2 Erubis Markaby ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end

  class Template
    extend ::Ramaze::Helper

    helper :link, :redirect

    # This finds the template for the given action on the current controller
    # there are some basic ways how you can provide an alternative path:
    #
    # Global.template_root = 'default/path'
    #
    # class FooController < Template::Ramaze
    #   trait :template_root => 'another/path'
    #   trait :index_template => :foo
    #
    #   def index
    #   end
    # end
    #
    # One feature also used in the above example is the custom template for
    # one action, in this case :index - now the template of :foo will be
    # used instead.

    def self.find_template action
      action = action.to_s
      custom_template = trait["#{action}_template".intern] ||
        self.class.trait["#{action}_template".intern]
      action = custom_template if custom_template

      path =
        if template_root = trait[:template_root] || trait[:template_root]
          template_root / action
        else
          Global.template_root / Global.mapping.invert[self] / action
        end
      path = File.expand_path(path)

      extensions = ancestors.find{|a| a.trait[:template_extensions]}.trait[:template_extensions]

      Dir["#{path}.{#{extensions.join(',')}}"].first
    end
  end
end
