module OKCMOA
  module Screening

    class << self

      # Parse a line of screenings.
      # A line is defined as an li tag in the HTML.
      # A line can contain multiple dates and times.
      # If the date is in the past, assume that it is for the following year.
      def parse_line(line)
        days_of_week, dates, times = line.split(', ')
        month, days = dates.split
        days.split('-').flat_map do |day|
          times.split(' & ').map do |time|
            date = Date.parse("#{month} #{day}")
            year = date < Date.today ? date.year + 1 : date.year
            DateTime.parse("#{year} #{month} #{day} #{time}")
          end
        end
      end

      def parse_list(ul_node)
        ul_node.css('li').flat_map do |li|
          parse_line(li.text)
        end
      end

    end

  end
end
