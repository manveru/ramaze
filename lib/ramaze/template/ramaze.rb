module Ramaze::Template
  class Ramaze
    trait :actionless => false
    class << self
      def handle_request request, action, *params
        controller = self.new
        template = controller.__send__(action, *params).to_s
        rendered = controller.send(:render, action).to_s
        template = rendered unless rendered.empty?
        template
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
				string.gsub!(/<% (.*?) %>/) do |m|
          "<?r #{$1} \n %{} ?>"
        end
                       
        string.gsub!(/<%= (.*?) %>/) do |m|
          "<?r #{$1} ?>"
        end
        
        string.gsub!(/#\[(.*?)\]\s*$/) do |m|
          "<?r #{$1} ?>"
        end

				string = "out.push(<<FOOBAR\n#{string}"
        
        string.gsub!(/<\?r (.*?) \?>/) do |m|
          "\nFOOBAR\n)\n out.push(#{$1})\n out.push(<<FOOBAR\n"
        end
        
        string << "FOOBAR\n)"

        puts string
        out = []
        eval(string)
				p out
        string = out.join
      rescue Object => ex
        error "something bad happened while transformation"
        error ex
      end
      string
    end

    def redirect target
      response.head['Location'] = target
      response.code = 303
      %{Please follow <a href="#{target}">#{target}</a>!}
    end
  end
end
