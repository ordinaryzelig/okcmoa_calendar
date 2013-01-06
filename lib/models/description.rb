module OKCMOA
  module Description

    class << self

      # The description will include the general description and
      # the film's information:
      #   director
      #   year
      #   country
      #   runtime
      #   rating
      #   film format
      #
      # Sometimes there is a paragraph before the screenings.
      # Include it if it exists and is not empty.
      #
      # Exclude the screening paragraphs.
      # Exclude the last paragraph which contains the video(s).
      def parse(post_content_node)
        paragraph_nodes = post_content_node.children.select { |node| node.name == 'p' }
        paragraphs = paragraph_nodes.map do |node|
          blank = node.content == ''
          next if blank
          contains_videos = node.css('iframe').any?
          next if contains_videos
          next if Screening.contains_screening_data?(node.text)

          convert_urls!(node)

          content = Iconv.iconv('utf-8//IGNORE', 'ascii', node.content).first
          content.gsub(/^"|"$/, '')
        end

        paragraphs.compact.join("\n\n")
      end

      def convert_urls!(node)
        node.css('a').each do |a_tag|
          a_tag.content = "#{a_tag.content} (#{a_tag[:href]})"
        end
        node
      end

    end

  end
end
