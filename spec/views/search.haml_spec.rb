require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "search.haml" do
  before(:each) do
    assigns[:results] =
      @results = {
      'rows' =>
      [
       { '_id' => 'id-one',   'title' => 'One',   'date' => '2009-04-15' },
       { '_id' => 'id-two',   'title' => 'Two',   'date' => '2009-04-14' },
       { '_id' => 'id-three', 'title' => 'Three', 'date' => '2009-04-13' },
      ]
    }
  end

  it "should display the recipe's title" do
    render("/views/search.haml")
    response.should have_selector("td", :content => 'One')
  end

  it "should display a second recipe" do
    render("/views/search.haml")
    response.should have_selector("td", :content => 'Two')
  end

  it "should display zebra strips" do
    render("/views/search.haml")
    response.should have_selector("tr", :class => "row1", :count => 1)
    response.should have_selector("tr", :class => "row0", :count => 2)
  end

  it "should link the title to the recipe" do
    render("/views/search.haml")
    response.should have_selector("td > a",
                                  :href => "/recipes/id-one",
                                  :content => "One")
  end

  it "should display the recipe's date" do
    render("/views/search.haml")
    response.should have_selector("td", :content => '2009-04-15')
  end
end
