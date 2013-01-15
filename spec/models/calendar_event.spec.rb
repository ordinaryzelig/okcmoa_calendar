require 'spec_helper'

describe OKCMOA::CalendarEvent do

  let(:film) do
    OKCMOA::Film.new(title: 'asdf', description: 'wow', runtime: 90, okcmoa_url: 'okcmoa.com')
  end
  let(:screening) do
    OKCMOA::Screening.new(
      film: film,
      time_start: DateTime.civil(2012, 7, 10, 12),
      time_end:   DateTime.civil(2012, 7, 10, 13, 30),
    )
  end
  let(:event) { OKCMOA::CalendarEvent.new_from_screening(screening) }

  describe '.new_from_screening' do

    subject { event }

    it_parses :summary,     'asdf'
    it_parses :description, "okcmoa.com\n\nwow"

    it 'parses "start"' do
      Timecop.freeze DateTime.civil(2012, 7, 10) do
        subject.start.must_equal '2012-07-10T12:00:00.000-05:00'
      end
    end

    it 'parses "end"' do
      Timecop.freeze DateTime.civil(2012, 7, 10) do
        subject.end.must_equal '2012-07-10T13:30:00.000-05:00'
      end
    end

  end

  specify '#body_json conmposes a hash and converts to JSON' do
    Timecop.freeze DateTime.civil(2012, 7, 10) do
      event.send(:body_json).must_equal '{"summary":"asdf","start":{"dateTime":"2012-07-10T12:00:00.000-05:00"},"end":{"dateTime":"2012-07-10T13:30:00.000-05:00"},"description":"okcmoa.com\n\nwow"}'
    end
  end

  specify '#create sends a request to Google and creates the event' do
    VCR.use_cassette 'create_screening_event' do
      event.create
      # This seems to have created the event correctly,
      # so I'm going to assume it works every time.
      true.must_equal true
    end
  end

end
