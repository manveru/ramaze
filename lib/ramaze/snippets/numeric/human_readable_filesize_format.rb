#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Numeric
  HUMAN_READABLE_FILESIZE_FORMAT = [
      ['%.1fT', 1 << 40],
      ['%.1fG', 1 << 30],
      ['%.1fM', 1 << 20],
      ['%.1fK', 1 << 10],
    ]

  def human_readable_filesize_format
    HUMAN_READABLE_FILESIZE_FORMAT.each do |format, size|
      return format % (self.to_f / size) if self >= size
    end

    self.to_s
  end
end

=begin
$microtest_verbose = true
$microtest_run     = true

require 'micro/test'

{ :description => 'format_human_filesize',
  1 << 0  => '1',
  1 << 10 => '1.0K',
  1 << 20 => '1.0M',
  1 << 30 => '1.0G',
}.test :human_readable_filesize_format
=end
