#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FormattingHelper
    private

    def number_format(n, delimiter = ',')
      delim_l, delim_r = delimiter == ',' ? %w[, .] : %w[. ,]
      h, r = n.to_s.split('.')
      [h.reverse.scan(/\d{1,3}/).join(delim_l).reverse, r].compact.join(delim_r)
    end

    # stolen and adapted from rails
    def time_diff from_time, to_time = Time.now, include_seconds = false
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round if include_seconds

      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
          case distance_in_seconds
            when 0..4   then 'less than 5 seconds'
            when 5..9   then 'less than 10 seconds'
            when 10..19 then 'less than 20 seconds'
            when 20..39 then 'half a minute'
            when 40..59 then 'less than a minute'
            else             '1 minute'
          end

        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then 'about 1 hour'
        when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2879      then '1 day'
        when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
        when 43200..86399    then 'about 1 month'
        when 86400..525959   then "#{(distance_in_minutes / 43200).round} months"
        when 525960..1051919 then 'about 1 year'
        else                      "over #{(distance_in_minutes / 525960).round} years"
      end
    end

  end
end
