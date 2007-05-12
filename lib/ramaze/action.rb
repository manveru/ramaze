#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Action < Struct.new('Action', :method, :params, :template)
    def to_s
      %{#<Action method=#{method.inspect}, params=#{params.inspect} template=#{template.inspect}>}
    end
  end
end
