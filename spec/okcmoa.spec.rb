require 'spec_helper'

describe OKCMOA do

  specify '.update_films creates new events for any recently updated screenings' do
    screenings = [OKCMOA::Screening.new(film: OKCMOA::Film.new, time_start: DateTime.now)]
    OKCMOA::Screening.stubs(:current).returns(screenings)
    OKCMOA::Screening.stubs(:last_import).returns([])
    OKCMOA::Screening.stubs(:write_last_import)

    screenings.first.expects :create_event
    OKCMOA.update_films
  end

end
