desc 'code coverage'
task :rcov => :clean do
  specs = Dir['spec/{ramaze,snippets}/**/*.rb']
  specs -= Dir['spec/ramaze/cache/common.rb']

  # we ignore adapter as this has extensive specs in rack already.
  ignore = %w[ gem rack bacon innate hpricot nagoro/lib/nagoro ]

  if RUBY_VERSION >= '1.8.7'
    ignore << 'begin_with' << 'end_with'
  end
  if RUBY_VERSION < '1.9'
    ignore << 'fiber'
  end

  ignored = ignore.join(',')
  cmd = "rcov --aggregate coverage.data --sort coverage -t --%s -x '#{ignored}' %s"

  while spec = specs.shift
    puts '', "Gather coverage for #{spec} ..."
    html = specs.empty? ? 'html' : 'no-html'
    sh(cmd % [html, spec]){|*a| }
  end
end
