module Macros

  def it_parses(attribute, expected_value)
    it "parses #{attribute}" do
      subject.send(attribute).must_equal expected_value
    end
  end

  def it_parses_screening_line(line, expected_screenings)
    it "parses #{line} into screenings" do
      Timecop.freeze Date.civil(2012, 7, 4) do
        OKCMOA::Screening.parse_line(line).must_equal expected_screenings
      end
    end
  end

end

MiniTest::Spec.extend Macros
