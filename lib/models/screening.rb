module OKCMOA
  class Screening

    include RailsStyleInitializer

    attr_accessor :film
    # time defined manuallyl because of stupid time zone crap.

    class << self

      # Parse a line of screening times, return DateTime.
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

      def current
        Film.all.flat_map(&:screenings)
      end

      def last_import
        if File.exist?(last_import_path)
          file = File.open(last_import_path)
          YAML.load(file.read)
        else
          []
        end
      end

      def last_import_path
        './tmp/screenings.yml'
      end

      def write_last_import(screenings)
        File.open(last_import_path, 'w+') do |f|
          f.write screenings.to_yaml
        end
      end

    end

    # =============================================
    # Comparison.
    # Compare film title and screening time.

    def ==(another_screening)
      self.film.title == another_screening.film.title && self.time == another_screening.time
    end
    alias_method :eql?, :==

    def hash
      quick_add_text.hash
    end

    # =============================================
    # UGH, time zones.

    # Strip any time zone crap.
    def time=(time)
      t = time.to_time.utc
      @time = DateTime.civil(t.year, t.month, t.day, t.hour, t.min)
    end

    def time
      @time.to_time.utc.to_datetime
    end

    # =============================================

    def create_event
      OKCMOA.client.api_client.execute(
        api_method: OKCMOA.client.service.events.quick_add,
        parameters: {
          'calendarId' => OKCMOA.config.films_calendar_id,
          'text'       => quick_add_text,
        }
      )
    end

    def quick_add_text
      "#{film.title} on #{time.strftime('%F %R')}"
    end

  end
end
