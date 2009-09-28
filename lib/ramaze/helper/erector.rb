#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erector'

module Ramaze

  # Allows you to use some shortcuts for Erector in your Controller.

  # use this inside your controller to directly build Erector 
  # Refer to the Erector-documentation and testsuite for more examples.
  # Usage:
  #   erector { h1 "Apples & Oranges" }                           #=> "<h1>Apples &amp; Oranges</h1>"
  #   erector { h1(:class => 'fruits&floots'){ text 'Apples' } }  #=> "<h1 class=\"fruits&amp;floots\">Apples</h1>"

  module Helper
    module Erector
     include ::Erector::Mixin
    end
  end
end

