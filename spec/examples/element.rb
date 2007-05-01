require 'spec/helper'

require 'examples/element'

context 'Element' do
  ramaze

  "<html>\n      <head>\n        <title>examples/element</title>\n      </head>\n      <body>\n        <h1>Test</h1>\n        \n      \n     <div class=\"sidebar\">\n       <a href=\"http://something.com\">something</a>\n     </div>\n     \n      <p>\n        Hello, World!\n      </p>\n    \n      </body>\n    </html>"

  specify do
    r = get('/')
    r.should.include '<title>examples/element</title>'
    r.should.include '<h1>Test</h1>'
    r.should.include '<a href="http://something.com">something</a>'
    r.should.include 'Hello, World!'
  end
end
