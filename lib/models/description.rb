module OKCMOA
  module Description

    class << self

      # Post content div contains paragraph tags with description and other information.
      # The description will include the general description and
      # the film's information:
      #   director
      #   year
      #   country
      #   runtime
      #   rating
      #   film format
      #
      # Sometimes there is a paratraph before the screenings.
      # Include it if it exists and is not empty.
      #
      # Exclude the last paragraph which contains the video(s).
      def parse(post_content_node)
        paragraph_nodes = post_content_node.children.select { |node| node.name == 'p' }
        paragraphs = paragraph_nodes.map do |node|
          blank = node.content == ''
          next if blank
          contains_videos = node.css('iframe').any?
          next if contains_videos

          content = Iconv.iconv('utf-8//IGNORE', 'ascii', node.content).first
          content.gsub(/^"|"$/, '')
        end

        paragraphs.compact.join("\n\n")
      end

    end

  end
end
