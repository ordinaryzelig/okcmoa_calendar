require 'nokogiri'

module Parser

  class << self

    def parse_event_links(html)
      doc = Nokogiri.HTML(html)
      a_tags = doc.css('.post-content a')
      a_tags.map { |tag| tag[:href] }
    end

  end

end
