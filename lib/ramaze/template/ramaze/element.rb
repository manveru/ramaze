#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # an Element is almost like an Controller, however, instead
  # of connecting actions to templates it is only used in
  # Ramaze::Template::Ramaze and can be used inside the
  # templates of the Controller as a simple wrapper.
  #
  # Example:
  #
  # Your Element called Page:
  #
  #   class Page < Element
  #     def render
  #       %{
  #        <html>
  #          <h1>
  #            #{@hash['title']}
  #          </h1>
  #          #{content}
  #        </html>
  #        }
  #     end
  #   end
  #
  # and one called SideBar
  #
  #   class SideBar < Element
  #     def render
  #       %{
  #         <a href="http://something.com">something</a>
  #        }
  #      end
  #    end
  #
  # and your template (any template for any action):
  #
  #   <Page title="Test">
  #     <SideBar />
  #     <p>
  #       Hello, World!
  #     </p>
  #   <Page>
  #
  # would result in:
  #
  #   <html>
  #     <h1>
  #       Test
  #     </h1>
  #     <p>
  #       Hello, World!
  #     </p>
  #   </html>

  class Element
    extend Ramaze::Helper

    helper :link, :redirect

    attr_accessor :content

    # this will be called by #transform, passes along the
    # stuff inside the tags for the element

    def initialize(content)
      @content = content
    end

    # The method that will be called upon to render the things
    # inside the element, you can access #content from here, which
    # contains the contents between the tags.
    #
    # It should answer with a String.

    def render *args
      @content
    end

    class << self
      # transforms all <Element> tags within the string, takes also
      # a binding to be compatible to the transform-pipeline, won't have
      # any use for it though.
      #
      # It also sets a instance-variable for you called @hash, which
      # contains the parameters you gave the <Element> tag.
      # See above for an example of writing and using them.

      def transform string = '', binding = nil
        string = string.to_s
        matches = string.scan(/<([A-Z][a-zA-Z0-9]*)(.*?)?>/)
        matches.each do |(klass, params)|
          next unless klass and string =~ /<\/#{klass}>/
          string.gsub!(/<#{klass}( .*?)?>(.*?)<\/#{klass}>/m) do |m|
            hash = demunge_passed_variables($1.to_s)
            k = constant(klass).new($2) rescue nil

            break m unless k and k.respond_to?(:render)
            k.instance_variable_set("@hash", hash)

            k.render
          end
        end
        string
      end

      # basically processes stuff like
      #   'foo="bar" foobar="baz"'
      # do NOT pass actual objects that cannot be simply read as a string
      # here, the information will be lost.

      def demunge_passed_variables(string)
        string.scan(/\s?(.*?)="(.*?)"/).inject({}) do |hash, (key, value)|
          hash.merge key => value
        end
      end
    end
  end
end
