desc 'download latest jquery and put in /lib/proto/public/js/jquery.js'
task :jquery do
  require 'open-uri'
  $stdout.sync = true

  File.open(PROJECT_JQUERY_FILE, 'w+') do |jquery|
    remote = open('http://code.jquery.com/jquery-latest.js')
    print "openend remote side, copying..."
    while chunk = remote.read(4096)
      print '.'
      jquery.write(chunk)
    end
    puts " done."
  end
end
