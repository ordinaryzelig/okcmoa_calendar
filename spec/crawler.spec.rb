require 'spec_helper'

describe Crawler do

  specify '.crawl_event_list scrapes OKCMOA website for list of events' do
    VCR.use_cassette 'film_list' do
      source = Crawler.crawl_event_list(:films)
      links = Parser.parse_event_links(source)
      links.wont_be_empty
    end
  end

end
