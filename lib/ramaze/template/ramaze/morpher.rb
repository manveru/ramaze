#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
begin
  require 'hpricot'

  module Ramaze
    class Morpher
      trait :transformer => [:if, :unless, :for]

      def self.transform template, bound = nil
        transformer = trait[:transformer].map{|t| t.to_s}.select do |t|
          template.include?("#{t}=")
        end

        return template if transformer.empty?

        hp = Hpricot(template)
        hp.each_child do |child|
          if child.elem?
            transformer.each do |attribute|
              if cond = child[attribute]
                old = child.to_html
                child.remove_attribute(attribute)
                template.gsub!(old, "<?r #{attribute} #{cond} ?>#{child.to_html}<?r end ?>")
              end
            end
          end
        end
        template
      end
    end
  end
rescue LoadError => ex
  puts ex
  puts "Please `gem install hpricot` to get Morpher"
  module Ramaze
    class Morpher
      def self.transform(template, bound = nil)
        template
      end
    end
  end
end
