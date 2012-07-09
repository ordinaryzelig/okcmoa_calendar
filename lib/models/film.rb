module OKCMOA
  class Film

    attr_accessor :description
    attr_accessor :screening_times
    attr_accessor :title
    attr_accessor :video_url

    include RailsStyleInitializer

    class << self

      # Crawl films list.
      # For each film url,
      #   get film HTML
      #   parse HTML into Film object.
      def all
        urls.map do |url|
          html = open(url).read
          film = parse(html)
        end
      end

      def screenings
        screenings =
          all.
          flat_map(&:screenings).
          sort_by(&:time)
      end

      def parse(html)
        doc = Nokogiri.HTML(html)

        description     = Description.parse(doc.css('.post-content'))
        screening_times = Screening.parse_list(doc.at_css('.post-content ul'))
        title           = doc.at_css('h1').text
        video_url       = doc.at_css('iframe')[:src]

        new(
          description:      description,
          screening_times:  screening_times,
          title:            title,
          video_url:        video_url,
        )
      end

    private

      def urls
        html = Crawler.crawl_event_list(:films)
        Parser.parse_event_links(html)
      end

    end

    def screenings
      screening_times.map do |screening_time|
        Screening.new(
          film: self,
          time: screening_time,
        )
      end
    end

  end
end
