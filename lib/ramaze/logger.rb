module Ramaze
  module Logger
    def debug *args
      if Global.mode != :live
        log 'd', *args
      end
    end

    def error e
      if Global.mode != :live
        log '! ', e.message
        log '!', e.backtrace.join("\n! ")
      end
    end

    def info *args
      if Global.mode != :live
        log '-', *args
      end
    end

    private

    def log *args
      puts args.map{|a| a.is_a?(String) ? a : a.inspect}.join(' ')
    end

    extend self
  end
end
