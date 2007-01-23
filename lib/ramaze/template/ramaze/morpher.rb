#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Morpher
    trait :morphs => ['if', 'unless', 'for']

    # This applies a morphing-replace for the template.
    #
    # To use the functionality of Morpher you will need to have hpricot
    # installed, you will get one error in case you don't and the method
    # will be replaced by a stub that simply returns the template.
    #
    # The method first checks if you use any morphers and just skips
    # the step if you don't, this should give quite some speedup for
    # smaller templates that don't use this functionality at all.
    # the check works by searching the morphs with appended '='
    # in the template. There may be a few cases where this won't work
    # since we cannot make any assumptions on the format.
    #
    # If you want to turn this functionality off, either remove Morpher
    # from:
    #   Ramaze::Template::Ramaze.trait[:transform_pipeline]
    # or do:
    #   Ramaze::Morpher.trait[:morphs] = []
    #
    # The latter is a tad slower, but i mention the possibility in case you
    # find good use for it.
    #
    # You can add your own morphers in Ramaze::Morpher.trait[:morphs]
    #
    # Please note that a morpher has to be converted from
    #   <tag morph="expression">content</tag>
    # to the format
    #   <?r morph expression ?><tag>content</tag><?r end ?>
    #
    # The expression will be terminated by ; in the templating, there will be
    # no 'do' or any parenthesis added.
    #
    # Since the functionality is best explained by examples, here they come.
    #
    # Example:
    #
    # if:
    #   <div if="@name">#@name</div>
    # morphs to:
    #   <?r if @name ?>
    #     <div>#@name</div>
    #   <?r end ?>
    #
    # unless:
    #   <div unless="@name">No Name</div>
    # morphs to:
    #   <?r unless @name ?>
    #     <div>No Name</div>
    #   <?r end ?>
    #
    # for:
    #   <div for="name in @names">#{name}</div>
    # morphs to:
    #   <?r for name in @names ?>
    #     <div>#{name}</div>
    #   <?r end ?>
    #
    # TODO:
    #   - Add pure Ruby implementation as a fallback.

    def self.transform template, bound = nil
      morphs = trait[:morphs].map{|t| t.to_s}.select do |t|
        template.include?("#{t}=")
      end

      return template if morphs.empty?

      require 'hpricot'

      hp = Hpricot(template)
      hp.each_child do |child|
        if child.elem?
          morphs.each do |attribute|
            if cond = child[attribute]
              old = child.to_html
              child.remove_attribute(attribute)
              template.gsub!(old, "<?r #{attribute} #{cond} ?>#{child.to_html}<?r end ?>")
            end
          end
        end
      end

      template

    rescue LoadError => ex
      error "Please install hpricot (for example via `gem install hpricot`) to get morphing"

      # replace this method with a stub that only returns the template.

      self.class_eval do
        def self.transform(template, bound = nil)
          template
        end
      end

      template
    end
  end
end
