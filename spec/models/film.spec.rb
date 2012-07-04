require 'spec_helper'

describe OKCMOA::Film do

  describe '.parse' do

    subject do
      html = fixture_file_content('film.html')
      OKCMOA::Film.parse(html)
    end

    it_parses :title, 'First Position'
    it_parses :screenings, [
      DateTime.civil(2012, 7, 5, 19, 30),
      DateTime.civil(2012, 7, 6, 17, 30),
      DateTime.civil(2012, 7, 6, 20, 00),
      DateTime.civil(2012, 7, 7, 17, 30),
      DateTime.civil(2012, 7, 7, 20, 00),
      DateTime.civil(2012, 7, 8, 14, 00),
    ]
    it_parses :description, <<-END.chomp
For the young dancers at the Youth America Grand Prix, one of the worlds most prestigious ballet competitions, lifelong dreams are at stake. With hundreds competing for a handful of elite scholarships and contracts, practice and discipline are paramount, and nothing short of perfection is expected. Bess Kargmans award-winning documentary, First Position, follows six young dancers as they prepare for a chance to enter the world of professional ballet, struggling through bloodied feet, near exhaustion and debilitating injuries all while navigating the drama of adolescence. A showcase of awe-inspiring talent, tenacity and passion, First Position paints a thrilling and moving portrait of the most gifted young ballet stars of tomorrow.
Director: Bess Kargman 2011 USA 94min. NR 35mm
    END
    it_parses :video_url, 'http://www.youtube.com/embed/SmiBXdBNIXE?fs=1&feature=oembed'

  end

end
