require 'spec_helper'

describe OKCMOA do

  specify '.films crawls, parses, and returns Film objects' do
    VCR.use_cassette 'films/first_position' do
      urls = ['http://www.okcmoa.com/see/films/first-position/']
      films = OKCMOA.stub :film_urls, urls do
        OKCMOA.films
      end

      films.size.must_equal 1
    end
  end

end
