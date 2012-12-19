module OKCMOA
  class Screening

    include RailsStyleInitializer

    attr_accessor :film
    # time_start, time_end defined manually because of time zone stuff.

    def initialize(atts = {})
      super
      # Default time_end to 1 hour after time_start.
      ts = self.time_start
      self.time_end ||=
        ts ?
        DateTime.new(ts.year, ts.month, ts.day, ts.hour + 1, ts.minute) : # 1 hour later.
        nil
    end

    class << self

      # Parse a line of screening times, return DateTime.
      # A line is defined as an li tag in the HTML.
      # A line can contain multiple dates and times.
      # If the date is more than 90 days past, assume that it is for the following year.
      def parse_line(line)
        days_of_week, dates, times = line.split(', ')
        month, days = dates.split
        days.split('-').flat_map do |day|
          times.split(' & ').map do |time|
            date = Date.parse("#{month} #{day}")
            more_than_3_months_in_past = (Date.today - date).to_i > 90
            year = more_than_3_months_in_past ? date.year + 1 : date.year
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
      self.film.title == another_screening.film.title &&
      self.time_start == another_screening.time_start &&
      self.time_end   == another_screening.time_end
    end
    alias_method :eql?, :==

    def hash
      quick_add_text.hash
    end

    # =============================================
    # UGH, time zones.

    # Define custom reader/writer for each time attribute.
    [:time_start, :time_end].each do |time_attr|

      define_method time_attr do
        read_time(time_attr)
      end

      define_method :"#{time_attr}=" do |time|
        assign_time time_attr, time
      end

    end

    # Strip any time zone crap.
    def assign_time(time_attr, time)
      t = time.to_time.utc
      adjusted_time = DateTime.civil(t.year, t.month, t.day, t.hour, t.min)
      instance_variable_set :"@#{time_attr}", adjusted_time
    end

    # Convert to UTC and return DateTime.
    def read_time(time_attr)
      time = instance_variable_get :"@#{time_attr}"
      time.to_time.utc.to_datetime if time
    end

    # =============================================

    def create_event
      CalendarEvent.new_from_screening(self).create
    end

    def quick_add_text
      "#{film.title} on #{time_start.strftime('%F %R')}"
    end

  end
end
