#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  class Knotify
    include Informing

    trait :present => 16

    # Please see for more information:
    # http://lukeplant.me.uk/articles.php?id=3
    def inform(tag, *messages)
      present = class_trait[:present]
      tag = tag.to_s.capitalize
      messages.flatten.each do |message|
        system(%{dcop knotify default notify Ramaze "#{tag}" "#{message}" '' '' #{present} 0})
      end
    end
  end
end
