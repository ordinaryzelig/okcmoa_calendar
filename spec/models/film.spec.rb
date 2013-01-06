require_relative '../spec_helper'

describe OKCMOA::Film do

  let(:film) do
    html = fixture_file_content('film.html')
    OKCMOA::Film.parse(html)
  end
  subject { film }

  describe '.parse' do

    it_parses :title, 'First Position'
    it_parses :video_url, 'http://www.youtube.com/embed/SmiBXdBNIXE?fs=1&feature=oembed'
    it_parses :runtime, 94
    it_parses :description, <<-END.chomp
For the young dancers at the Youth America Grand Prix, one of the worlds most prestigious ballet competitions, lifelong dreams are at stake. With hundreds competing for a handful of elite scholarships and contracts, practice and discipline are paramount, and nothing short of perfection is expected. Bess Kargmans award-winning documentary, First Position, follows six young dancers as they prepare for a chance to enter the world of professional ballet, struggling through bloodied feet, near exhaustion and debilitating injuries all while navigating the drama of adolescence. A showcase of awe-inspiring talent, tenacity and passion, First Position paints a thrilling and moving portrait of the most gifted young ballet stars of tomorrow.

Director: Bess Kargman 2011 USA 94min. NR 35mm

Video: http://www.youtube.com/embed/SmiBXdBNIXE?fs=1&feature=oembed
    END

    it 'parses :screening_times' do
      Timecop.freeze(Date.civil(2012, 1, 1)) do
        expected_screening_times = [
          DateTime.civil(2012, 7, 5, 19, 30),
          DateTime.civil(2012, 7, 6, 17, 30),
          DateTime.civil(2012, 7, 6, 20, 00),
          DateTime.civil(2012, 7, 7, 17, 30),
          DateTime.civil(2012, 7, 7, 20, 00),
          DateTime.civil(2012, 7, 8, 14, 00),
        ]
        subject.screening_times.must_equal expected_screening_times
      end
    end

  end

  specify '#screenings returns Screening objects with film and screening times' do
    screenings = film.screenings
    screenings.map(&:class).uniq.must_equal [OKCMOA::Screening]
    screenings.map(&:time_start).must_equal film.screening_times
    screenings.map(&:film).uniq.must_equal [film]
  end

  specify '.all crawls, parses, and returns Film objects' do
    VCR.use_cassette 'films/first_position' do
      urls = ['http://www.okcmoa.com/see/films/first-position/']
      films = OKCMOA::Film.stub :urls, urls do
        OKCMOA::Film.all
      end

      films.size.must_equal 1
    end
  end

  specify ".screenings returns all films' screenings in order of time" do
    films = 2.times.map do |idx|
      OKCMOA::Film.new(
        title:           idx,
        screening_times: 2.times.map { Date.civil(2012, 1, 30 - idx) },
        runtime:    90,
      )
    end
    OKCMOA::Film.stub :all, films do
      OKCMOA::Film.screenings.must_equal films.flat_map(&:screenings).reverse
    end
  end

  specify '.parse raises ParseError if exception raised' do
    proc { OKCMOA::Film.parse('') }.must_raise OKCMOA::Film::ParseError
  end

end
