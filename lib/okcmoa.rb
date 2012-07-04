require 'bundler/setup'
Bundler.require

require './lib/crawler'
require './lib/parser'

Dir['./util/**/*.rb'].each { |f| require f }
Dir['./lib/models/**/*.rb'].each { |f| require f }

module OKCMOA

  class << self

    # Crawl films list.
    # For each film url,
    #   get film HTML
    #   parse HTML into Film object.
    def films
      film_urls.map do |url|
        html = open(url).read
        film = Film.parse(html)
      end
    end

  private

    def film_urls
      html = Crawler.crawl_event_list(:films)
      Parser.parse_event_links(html)
    end

  end

end
