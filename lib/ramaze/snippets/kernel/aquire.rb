module Kernel

  # Example:
  #   aquire 'foo/bar/*'
  # requires all files inside foo/bar - recursive
  # can take multiple parameters, it's mainly used to require all the
  # snippets.

  def aquire *files
    files.each do |file|
      require file if %w(rb so).any?{|f| File.file?("#{file}.#{f}")}
      $:.each do |path|
        Dir[File.join(path, file, '*.rb')].each do |file|
          require file
        end
      end
    end
  end
end
