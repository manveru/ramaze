module Ramaze::Template
  class Ramaze
    trait :actionless => false
    class << self
      def handle_request request, action, *params
        controller = self.new
        template = controller.__send__(action, *params).to_s
        template << controller.send(:render, action)
      end
    end

    private

    include Trinity

    def render template
      path = File.join(Global.template_root, Global.mapping.invert[self.class], template)

      exts = %w[rmze xhtml html]

      files = exts.map{|ext| "#{path}.#{ext}"}
      file = files.find{|file| File.file?(file)}.to_s

      if File.exist?(file)
        info "transforming #{file}"
        transform(File.read(file))
      else
        ''
      end
    end

    def transform string, ivs = {}
      begin
=begin
        string.gsub!(/<(.*?) for="(.*?)" (.*?)>/) do
          %{#{$1} #[ for #{$2} { #{$3} } ]}
        end
=end
        string.gsub!(/#\[(.*?)\]/) do
          puts $1
          eval($1)
        end
      rescue Object => ex
        error "something bad happened while transformation"
        error ex
        string
      end
    end

    def redirect target
      response.head['Location'] = target
      response.code = 303
      %{Please follow <a href="#{target}">#{target}</a>!}
    end
  end
end
