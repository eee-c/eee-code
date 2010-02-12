require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "search.haml" do
  before(:each) do
    assigns[:results] = {
      'skip'       => 0,
      'limit'      => 20,
      'total_rows' => 100,
      'rows' => [
                 { 'id'     => '2009-04-15-one',
                   'fields' => { 
                     'title' => 'One',
                     'date'  => '2009-04-15' 
                   } 
                 },
                 { 'id' => '2009-04-14-two',
                   'fields' => { 
                     'title' => 'Two',
                     'date'  => '2009-04-14' 
                   }
                 },
                 { 'id' => '2009-04-13-three',
                   'fields' => {
                     'title' => 'Three',
                     'date'  => '2009-04-13' 
                   }
                 },
                ]
    }

    assigns[:query] = "foo"

    stub!(:partial)
  end

  it "should display a form to refine your search" do
    should_receive(:partial).
      with(:_search_form)
    render("/views/search.haml")
    # response.should have_selector("form",
    #                               :action => "/recipes/search") do |form|
    #   form.should have_selector("input", :name => "q")
    # end
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
                                  :href => "/recipes/2009/04/15/one",
                                  :content => "One")
  end

  it "should display the recipe's date" do
    render("/views/search.haml")
    response.should have_selector("td", :content => '2009-04-15')
  end

  it "should link to sort by date" do
    assigns[:query] = "foo"
    render("/views/search.haml")
    response.should have_selector("th > a",
                                  :href => "/recipes/search?q=foo&sort=sort_title",
                                  :content => "Name")
  end
end
