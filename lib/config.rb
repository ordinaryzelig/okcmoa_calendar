module OKCMOA
  class Config

    attr_reader :films_calendar_id

    def initialize
      @films_calendar_id = ENV['FILMS_CALENDAR_ID']
    end

  end
end
