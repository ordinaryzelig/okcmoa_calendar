module OKCMOA
  class Film

    attr_accessor :description
    attr_accessor :screenings
    attr_accessor :title
    attr_accessor :video_url

    include RailsStyleInitializer

    class << self

      def parse(html)
        doc = Nokogiri.HTML(html)

        description = Description.parse(doc.css('.post-content'))
        screenings  = Screening.parse_list(doc.at_css('.post-content ul'))
        title       = doc.at_css('h1').text
        video_url   = doc.at_css('iframe')[:src]

        new(
          description: description,
          screenings:  screenings,
          title:       title,
          video_url:   video_url,
        )
      end

    end

  end
end
