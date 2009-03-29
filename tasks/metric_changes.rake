namespace :metric do
  desc 'committed changes per file according to git'
  task 'changes' do
    $stdout.sync = true
    out = lambda{|changes, rb| puts("%4d %s" % [changes, rb]) }
    changes = {}

    print 'counting changes '

    Dir['lib/**/*.rb'].each do |rb|
      changes = `git-log --pretty=oneline '#{rb}'`.count("\n")
      print '.'
      # out[changes, rb]
      changes[rb] = changes
    end
    puts ' done.'

    sorted = changes.sort_by{|r,c| c }.reverse
    puts "Top 20:"
    sorted.first(20).each{|(r,c)| out[c,r] }
    puts "Bottom 20:"
    sorted.last(20).each{|(r,c)| out[c,r] }
  end
end
