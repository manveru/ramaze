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

      def helper *syms
        syms.each do |sym|
          load "ramaze/helper/#{sym}.rb"
          include ::Ramaze.const_get("#{sym.to_s.capitalize}Helper")
        end
      end
    end

    private

    include Trinity

    helper :link, :redirect

    def breakout
      nil
    end

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
      a, e = "\n<<FOOBARABOOF_RAMAZE\n", "\nFOOBARABOOF_RAMAZE\n"
      bufadd = "out << "
      begin
        string.gsub!(/<% (.*?) %>/) do |m|
          "#{e} #{$1}; #{bufadd} #{a}"
        end

        string.gsub!(/<%= (.*?) %>/) do |m|
          "#{e} #{bufadd} (#{$1}); #{bufadd} #{a}"
        end

        string.gsub!(/<?r (.*?) ?>/) do |m|
          "#{e} #{bufadd} (#{$1}); #{bufadd} #{a}"
        end

        # this one should not be used until we find and solution
        # that allows for stuff like
        # #[@foo]!
        # we just don't allow anything except space or newline
        # after the expression #[] to make it sane
        string.gsub!(/#\[(.*?)\]\s*$/) do |m|
          "#{e} #{bufadd} (#{$1}); #{bufadd} #{a}"
        end

        out = []
        final = "#{bufadd} #{a}"
        final << string
        final << e
        eval(final)
        out.map! do |line|
          line.to_s.chomp
        end
        string = out.join.strip
      rescue Object => ex
        error "something bad happened while transformation"
        error ex
      end
      string
    end
  end
end
