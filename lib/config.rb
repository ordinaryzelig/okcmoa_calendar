require './lib/verbose'

module OKCMOA
  class Config

    attr_accessor :films_calendar_id
    attr_accessor :verbose

    def initialize
      @films_calendar_id = ENV['FILMS_CALENDAR_ID']
    end

  end
end
