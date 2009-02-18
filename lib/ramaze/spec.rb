require 'ramaze'
require 'bacon'

require 'innate/spec'

SPEC_REQUIRE_DEPENDENCY = {
  'sequel' => %w[sqlite3 sequel_model sequel_core]
}

# require each of the following and rescue LoadError, telling you why it failed.
def spec_require(*following)
  following << following.map{|f| SPEC_REQUIRE_DEPENDENCY[f] }
  following.flatten.uniq.compact.reverse.each do |file|
    require file.to_s
  end
rescue LoadError => ex
  puts ex
  puts "Can't run #{$0}: #{ex}"
  puts "Usually you should not worry about this failure, just install the"
  puts "library and try again (if you want to use that feature later on)"
  exit
end
