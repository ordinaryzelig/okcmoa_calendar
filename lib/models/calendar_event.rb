module OKCMOA
  class CalendarEvent

    include RailsStyleInitializer

    attr_accessor :summary
    attr_accessor :description
    attr_accessor :start
    attr_accessor :end

    class << self

      def new_from_screening(screening)
        film = screening.film
        description = "#{film.okcmoa_url}\n\n#{film.description}"
        new(
          summary:      screening.film.title,
          description:  description,
          start:        google_time_str(screening.time_start),
          end:          google_time_str(screening.time_end),
        )
      end

    private

      # Force use of Google's time format they used in the Ruby example.
      def google_time_str(time)
        timezone = time.to_time.localtime.zone
        zone_offset = Time.zone_offset(timezone) / 60 / 60
        zone_digit = zone_offset.to_s[/\d/]
        time.strftime("%FT%R:00.000-0#{zone_digit}:00")
      end

    end

    def create
      OKCMOA.client.api_client.execute(
        api_method: OKCMOA.client.service.events.insert,
        parameters: {'calendarId' => OKCMOA.config.films_calendar_id},
        body:       body_json,
        headers:    {'Content-Type' => 'application/json'},
      )
    end

  private

    def body_json
      body_hash = {
        'summary'     => summary,
        'start'       => {'dateTime' => start},
        'end'         => {'dateTime' => self.end},
        'description' => description,
      }
      JSON.dump(body_hash)
    end

  end
end
