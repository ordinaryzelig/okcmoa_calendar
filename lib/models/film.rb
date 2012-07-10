module OKCMOA
  class Film

    attr_accessor :description
    attr_accessor :screening_times
    attr_accessor :title
    attr_accessor :video_url
    attr_accessor :runtime

    include RailsStyleInitializer

    class << self

      # Crawl films list.
      # For each film url,
      #   get film HTML
      #   parse HTML into Film object.
      def all
        urls.map do |url|
          OKCMOA.puts url
          html = open(url).read
          film = parse(html)
        end
      end

      def screenings
        screenings =
          all.
          flat_map(&:screenings).
          sort_by(&:time_start)
      end

      def parse(html)
        doc = Nokogiri.HTML(html)

        video_url       = doc.at_css('iframe')[:src]
        description     = Description.parse(doc.css('.post-content'))
        description    += "\n\nVideo: #{video_url}" if video_url
        screening_times = Screening.parse_list(doc.at_css('.post-content ul'))
        title           = doc.at_css('h1').text
        runtime    = parse_runtime(description)

        new(
          description:      description,
          screening_times:  screening_times,
          title:            title,
          video_url:        video_url,
          runtime:     runtime,
        )
      end

    private

      def urls
        OKCMOA.puts 'get URLs'
        html = Crawler.crawl_event_list(:films)
        Parser.parse_event_links(html)
      end

      def parse_runtime(description)
        match_data = description.match(/(?<minutes>\d+)min/)
        match_data[:minutes].to_i if match_data
      end

    end

    def screenings
      screening_times.map do |screening_time|
        Screening.new(
          film: self,
          time_start: screening_time,
          time_end:   screening_time + (runtime / 60.0 / 24.0),
        )
      end
    end

  end
end
