require 'spec_helper'

describe Parser do

  specify '.parse_event_links' do
    html = fixture_file_content('films_list.html')
    hrefs = Parser.parse_event_links(html)
    urls = [
      'http://www.okcmoa.com/see/films/first-position/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-the-well-diggers-daughter/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-the-painting/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-goodbye-first-love/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-polisse/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-americano/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-tales-of-the-night/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-the-fairy/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-nobody-else-but-you/',
      'http://www.okcmoa.com/see/films/2012-french-cinema-week-children-of-paradise/',
    ]
    hrefs.must_equal urls
  end

end
