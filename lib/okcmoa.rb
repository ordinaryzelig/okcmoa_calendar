require 'bundler/setup'
Bundler.require

require './lib/config'

require './lib/crawler'
require './lib/parser'

require './lib/client'
require './lib/s3'

Dir['./util/**/*.rb'].each { |f| require f }
Dir['./lib/models/**/*.rb'].each { |f| require f }

module OKCMOA

  class << self

    def client
      @client ||= Client.new
    end

    def s3
      @s3 = self::S3.new
    end

    def update_films
      current_screenings = Screening.current
      recently_updated = current_screenings - Screening.last_import
      recently_updated.each do |screening|
        screening.create_event
      end
      Screening.write_last_import(current_screenings) unless recently_updated.empty?
    end

    def config
      @config ||= self::Config.new
    end

  end

end
