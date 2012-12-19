require 'spec_helper'

describe OKCMOA::Screening do

  include S3Helpers

  before do
    OKCMOA::Screening.instance_variable_set(:@s3_object, nil)
  end

  let(:film) do
    OKCMOA::Film.new(
      title: 'asdf',
      description: 'in a world...',
      video_url:   'http://youtube.com/watch_this',
    )
  end

  it_parses_screening_line 'Thursday, July 5, 7:30pm', [DateTime.civil(2012, 7, 5, 19, 30)]
  it_parses_screening_line 'Friday & Saturday, July 6-7, 5:30pm & 8pm', [
    DateTime.civil(2012, 7, 6, 17, 30),
    DateTime.civil(2012, 7, 6, 20, 00),
    DateTime.civil(2012, 7, 7, 17, 30),
    DateTime.civil(2012, 7, 7, 20, 00),
  ]
  it_parses_screening_line 'Sunday, July 8, 2pm',  [DateTime.civil(2012, 7, 8, 14, 00)]
  it_parses_screening_line 'Tuesday, July 3, 2pm', [DateTime.civil(2012, 7, 3, 14, 00)]
  it_parses_screening_line 'Monday, Jan 3, 2pm',   [DateTime.civil(2013, 1, 3, 14, 00)]

  specify '.parse_list parses ul tag and returns screening dates' do
    doc = node_from_fixture_file('film.html')
    ul_node = doc.at_css('.post-content ul')
    dates = OKCMOA::Screening.parse_list(ul_node)
    dates.size.must_equal 6
  end

  it 'is uniquely identified by film title and time' do
    screening_1 = OKCMOA::Screening.new(
      film:       film,
      time_start: DateTime.civil(2012, 7, 10, 19, 30),
      time_end:   DateTime.civil(2012, 7, 10, 21, 00),
    )
    yaml = <<END
--- !ruby/object:OKCMOA::Screening
film: !ruby/object:OKCMOA::Film
  title: asdf
  description: in a world...
  video_url: http://youtube.com/watch_this
time_start: !ruby/object:DateTime 2012-07-10 14:30:00.000000000 -05:00    
time_end: !ruby/object:DateTime 2012-07-10 16:00:00.000000000 -05:00    
END
    screening_2 = YAML.load(yaml)
    screenings = [screening_1, screening_2]
    screening_1.must_equal screening_2
    screenings.uniq.size.must_equal 1
    (screenings - [screening_1]).must_be_empty
  end

  specify '#create_event creates event in Google calendar' do
    screening = OKCMOA::Screening.new(
      film:       film,
      time_start: DateTime.civil(2012, 7, 9, 19, 30),
      time_end:   DateTime.civil(2012, 7, 9, 21, 30),
    )
    OKCMOA::CalendarEvent.any_instance.expects(:create)
    screening.create_event
  end

  specify '#quick_add_text' do
    screening = OKCMOA::Screening.new(
      film:       film,
      time_start: DateTime.civil(2012, 7, 9, 19, 30),
    )
    screening.quick_add_text.must_equal 'asdf on 2012-07-09 19:30'
  end

  specify '.s3_object fetches object from S3' do
    VCR.use_cassette 's3_screenings.yml' do
      use_test_s3_credentials
      object = OKCMOA::Screening.send :s3_object
      object.content.must_equal fixture_file_content('screenings.yml')
    end
  end

  specify '.write_last_import replaces S3 object with new one with current screenings' do
    VCR.use_cassette 'write_last_import' do
      use_test_s3_credentials
      OKCMOA::Screening.write_last_import([])
      s3_object = OKCMOA::Screening.send :s3_object
      s3_object.content(true).must_equal "--- []\n"
    end
  end

  it 'defaults #time_end to 1 hour after time_start' do
    screening = OKCMOA::Screening.new(time_start: DateTime.civil(2012, 8, 5, 8, 25))
    screening.time_end.must_equal DateTime.civil(2012, 8, 5, 9, 25)
  end

end
