#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Informing
    def tag_inform(tag, meth, *strings)
      strings.each do |string|
        string = (string.respond_to?(:to_str) ? string : string.send(meth))
        inform(tag, string)
      end
    end

    def info(*strings)
      tag_inform(:info, :to_s, *strings)
    end

    def warn(*strings)
      tag_inform(:warn, :to_s, *strings)
    end

    def debug(*strings)
      tag_inform(:debug, :inspect, *strings)
    end

    alias << debug

    def error(ex)
      if ex.respond_to?(:exception)
        message = ex.backtrace[0..Global.backtrace_size]
        message.map!{|m| m.gsub(/^#{Dir.pwd}/, '.') }
        message.unshift(ex.inspect)
      else
        message = ex.to_s
      end
      tag_inform(:error, :to_s, *message)
    end

    def inform(*args)
      raise "#inform should be implemented by an instance including this module (#{self})"
    end

    def shutdown
    end

    # stub for WEBrick

    def debug?
      false
    end
  end
end
