require 'open-uri'

module Crawler

  BASE_URI = 'http://www.okcmoa.com/see'

  class << self

    def crawl_event_list(page_name)
      uri = uri(page_name)
      response = open(uri)
      response.read
    end

    def uri(page_name)
      "#{BASE_URI}/#{page_name}"
    end

  end

end
