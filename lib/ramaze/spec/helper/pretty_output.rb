module Bacon
  module PrettyOutput
    NAME = ''

    def handle_specification(name)
      NAME.replace name
			puts NAME
      yield
			puts
    end

    def handle_requirement(description)
	    print "- #{description}"
      error = yield

      unless error.empty?
        if defined?(Ramaze::Informing)
          puts '', " #{NAME} -- #{description} [FAILED]".center(70, '-'), ''
          colors = Ramaze::Informer::COLORS

          until RamazeLogger.log.empty?
            tag, line = RamazeLogger.log.shift
            out = "%6s | %s" % [tag.to_s, line]
            puts out.send(colors[tag])
          end
        end

        general_error
      end
    end

    def general_error
      puts "", ErrorLog
      ErrorLog.scan(/^\s*(.*?):(\d+): #{NAME} - (.*?)$/) do
        puts "#{ENV['EDITOR'] || 'vim'} #$1 +#$2 # #$3"
      end
      ErrorLog.replace ''
    end

    def handle_summary
	    puts
      puts "%d tests, %d assertions, %d failures, %d errors" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end
  end
end

if defined?(Ramaze::Informing)
  module Ramaze
    class SpecLogger
      include Ramaze::Informing
      include Enumerable

      attr_accessor :log

      def initialize
        @log = []
      end

      def each
        @log.each{|e| yield(e) }
      end

      def inform(tag, str)
        @log << [tag, str]
      end
    end
  end

  module Bacon::PrettyOutput
    RamazeLogger = Ramaze::SpecLogger.new
    Ramaze::Inform.loggers = [RamazeLogger]
  end
end
