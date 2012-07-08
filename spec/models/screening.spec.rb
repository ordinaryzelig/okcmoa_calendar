require 'spec_helper'

describe OKCMOA::Screening do

  it_parses_screening_line 'Thursday, July 5, 7:30pm', [DateTime.civil(2012, 7, 5, 19, 30)]
  it_parses_screening_line 'Friday & Saturday, July 6-7, 5:30pm & 8pm', [
    DateTime.civil(2012, 7, 6, 17, 30),
    DateTime.civil(2012, 7, 6, 20, 00),
    DateTime.civil(2012, 7, 7, 17, 30),
    DateTime.civil(2012, 7, 7, 20, 00),
  ]
  it_parses_screening_line 'Sunday, July 8, 2pm',  [DateTime.civil(2012, 7, 8, 14, 00)]
  it_parses_screening_line 'Tuesday, July 3, 2pm', [DateTime.civil(2013, 7, 3, 14, 00)]

  specify '.parse_list parses ul tag and returns screening dates' do
    doc = node_from_fixture_file('film.html')
    ul_node = doc.at_css('.post-content ul')
    dates = OKCMOA::Screening.parse_list(ul_node)
    dates.size.must_equal 6
  end

end
