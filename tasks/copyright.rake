desc "add copyright to all .rb files in the distribution"
task :copyright do
  ignore = File.readlines('doc/LEGAL').
    select{|line| line.strip!; File.exist?(line)}.
    map{|file| File.expand_path(file)}

  puts "adding copyright to files that don't have it currently"
  puts PROJECT_COPYRIGHT
  puts

  Dir['{lib,test}/**/*{.rb}'].each do |file|
    file = File.expand_path(file)
    next if ignore.include? file
    lines = File.readlines(file).map{|l| l.chomp}
    unless lines.first(PROJECT_COPYRIGHT.size) == PROJECT_COPYRIGHT
      puts "#{file} seems to need attention, first 4 lines:"
      puts lines[0..3]
      puts
    end
  end
end
