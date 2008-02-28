# start.ru for ramaze apps
# use thin>=0.6.3
# thin start -r start.ru

require 'start'
Ramaze.trait[:essentials].delete Ramaze::Adapter
Ramaze.start :force => true
run Ramaze::Adapter::Base
