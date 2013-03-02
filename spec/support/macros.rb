module Macros

  def it_parses(attribute, expected_value)
    it "parses #{attribute}" do
      subject.send(attribute).must_equal expected_value
    end
  end

  def it_parses_screening_line(line, expected_screenings)
    it "parses '#{line}' into screenings" do
      Timecop.freeze Date.civil(2012, 7, 4) do
        OKCMOA::Screening.contains_screening_data?(line).must_equal true, 'Regex failed to match screening line'
        OKCMOA::Screening.parse_line(line).must_equal expected_screenings
      end
    end
  end

  def it_wont_parse_line_as_screening(line)
    it "does not parse '#{line}' as screening" do
      OKCMOA::Screening.contains_screening_data?(line).wont_equal true, 'Regex expected NOT to match line as screening'
    end
  end

  def it_converts_to_google_time(time, expected_google_time)
    it "converts #{time.inspect} to google time #{expected_google_time.inspect}" do
      OKCMOA::CalendarEvent.send(:google_time_str, time).must_equal expected_google_time
    end
  end

end

MiniTest::Spec.extend Macros
