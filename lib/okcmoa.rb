require 'bundler/setup'
Bundler.require

require './lib/config'
require './lib/mailer'

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
      @s3 ||= self::S3.new
    end

    def update_films
      current_screenings = Screening.current

      recently_updated = current_screenings - Screening.last_import
      OKCMOA.puts "recent screenings: #{recently_updated.size}"

      recently_updated.each do |screening|
        begin
          OKCMOA.puts "creating event: '#{screening.film.title} @ #{screening.time_start}'"
          screening.create_event
        rescue
          raise $!
        end
      end

      Screening.write_last_import(current_screenings) unless recently_updated.empty?
    end

    def config
      @config ||= self::Config.new
    end

  end

end
