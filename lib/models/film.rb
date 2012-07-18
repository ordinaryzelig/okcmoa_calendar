module OKCMOA
  class Film

    attr_accessor :description
    attr_accessor :screening_times
    attr_accessor :runtime
    attr_accessor :title
    attr_accessor :video_url
    attr_accessor :okcmoa_url

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
          film.okcmoa_url = url
          film
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

        title           = doc.at_css('h1').text
        video_url       = parse_video_url(doc)
        description     = Description.parse(doc.css('.post-content'))
        description    += "\n\nVideo: #{video_url}" if video_url
        screening_times = Screening.parse_list(doc.at_css('.post-content ul'))
        runtime         = parse_runtime(description)

        new(
          description:      description,
          screening_times:  screening_times,
          title:            title,
          video_url:        video_url,
          runtime:          runtime,
        )
      rescue Exception => ex
        raise ParseError.new(title, ex)
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

      def parse_video_url(doc)
        iframe = doc.at_css('iframe')
        iframe[:src] if iframe
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

    class ParseError < StandardError
      def initialize(title, orig_exception)
        super "Error parsing '#{title}': #{orig_exception.message}"
        set_backtrace = orig_exception.backtrace
      end
    end

  end
end
