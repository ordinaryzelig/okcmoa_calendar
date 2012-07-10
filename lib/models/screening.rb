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
        YAML.load(s3_object.content)
      end

      def write_last_import(screenings)
        s3_object.content = screenings.to_yaml
        s3_object.save
      end

    private

      def s3_object_name
        'screenings.yml'
      end

      def s3_object
        return @s3_object if @s3_object
        @s3_object = OKCMOA.s3.bucket.objects.find(s3_object_name)
        @s3_object.content(true) # Need to reload when using #find.
        @s3_object
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
