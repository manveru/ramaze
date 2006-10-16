module Ramaze
  module Logger
    def debug *args
      unless [:live, :stage].include?(Global.mode)
        log 'd', *args
      end
    end

    def error e
      if Global.mode != :live
        if e.respond_to?(:message)
          log '! ', e.message
          log '!', e.backtrace.join("\n! ")
        else
          log '! ', e
        end
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
    include self
  end
end
