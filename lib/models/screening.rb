module OKCMOA
  class Screening

    include RailsStyleInitializer

    SCREENINGS_FILE_NAME = 'screenings.json'

    attr_accessor :film
    # time_start, time_end defined manually because of time zone stuff.
    # attr_accessor :time_start
    # attr_accessor :time_end

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
      # A line can contain multiple dates and times.
      # If the date is more than 90 days past, assume that it is for the following year.
      def parse_line(line)
        month, days, times = screening_match_data(line)

        day_start, day_end = days.split('-')
        day_end ||= day_start
        day_range = (day_start..day_end)

        day_range.flat_map do |day|
          times.split(/\s*&\s*/).map do |time|
            date = Date.parse("#{month} #{day}")

            more_than_3_months_in_past = (Date.today - date).to_i > 90
            year = more_than_3_months_in_past ? date.year + 1 : date.year

            DateTime.parse("#{year} #{month} #{day} #{time}")
          end
        end
      end

      def parse_list(list_node)
        ul_list = list_node.css('ul li')
        p_list  = list_node.css('p')
        (ul_list + p_list).flat_map do |li|
          line_text = li.text
          next nil unless contains_screening_data?(line_text)
          parse_line(line_text)
        end.compact
      end

      def current
        Film.all.flat_map(&:screenings)
      end

      def last_import
        screenings_atts = JSON.parse(s3_object_content)
        screenings_atts.map do |atts|
          new(
            film:       Film.new(title: atts.fetch('title')),
            time_start: DateTime.parse(atts.fetch('time_start')),
            time_end:   DateTime.parse(atts.fetch('time_end')),
          )
        end
      end

      def write_last_import(screenings)
        s3_object.content = JSON.pretty_generate(screenings)
        s3_object.save
      end

      def contains_screening_data?(text)
        screening_match_data(text).all?
      end

      def screening_match_data(text)
        %r{
          (?<month>(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*)
          \W*
          (?<days>(\d+-?)+)
          \W*
          (?<times>(\d+:?\d*\s*[ap]\.?m\.?\s*&?\s*)+) (?# am/pm/a.m./p.m.)
        }xi =~ text

        #ap month
        #ap days
        #ap times

        [month, days, times]
      end

    private

      def s3_object
        return @s3_object if @s3_object
        @s3_object = OKCMOA.s3.bucket.objects.find(SCREENINGS_FILE_NAME)
        @s3_object.content(true) # Need to reload when using #find.
        @s3_object
      end

      def s3_object_content
        s3_object.content
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

    def to_json(*args)
      {
        title:       film.title,
        time_start:  time_start,
        time_end:    time_end,
      }.to_json(*args)
    end

  end
end
