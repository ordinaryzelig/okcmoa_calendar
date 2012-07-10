require 'spec_helper'

describe OKCMOA::Description do

  specify '.parse parses description from post_content_node' do
    post_content_node = node_from_fixture_file('film.html').at_css('.post-content')
    description = OKCMOA::Description.parse(post_content_node)
    expected_description = <<-END.chomp
For the young dancers at the Youth America Grand Prix, one of the worlds most prestigious ballet competitions, lifelong dreams are at stake. With hundreds competing for a handful of elite scholarships and contracts, practice and discipline are paramount, and nothing short of perfection is expected. Bess Kargmans award-winning documentary, First Position, follows six young dancers as they prepare for a chance to enter the world of professional ballet, struggling through bloodied feet, near exhaustion and debilitating injuries all while navigating the drama of adolescence. A showcase of awe-inspiring talent, tenacity and passion, First Position paints a thrilling and moving portrait of the most gifted young ballet stars of tomorrow.

Director: Bess Kargman 2011 USA 94min. NR 35mm
    END
    description.must_equal expected_description
  end

end
