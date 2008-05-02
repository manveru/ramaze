desc 'Apply a patch bundle to darcs repo'
task :apply do
  bundle = ENV['BUNDLE'] || ENV['bundle'] || 'bundle'
  sh "darcs apply -v --reply=ramaze@googlegroups.com #{bundle}"
end

desc "Wrap up bundle and send to mailinglist"
task 'darcs:bundle' do
  sh "darcs send -O"
  Dir['*.dpatch'].each do |dpatch|
    basename = File.basename(dpatch, '.dpatch')
    sh "tar -cjf #{basename}.tar.bz2 #{dpatch}"
  end
end
