require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "index.haml" do
  before(:each) do
    assigns[:meals] = [{ "_id"     => "2009-05-15",
                         "date"    => "2009-05-15",
                         "title"   => "Bar",
                         "summary" => "Bar summary",
                         "menu"    => [],
                         "_attachments" => {"image1.jpg" => { }}
                       }]
    assigns[:older_meals] = []
  end

  it "should include the meal titles" do
    render("/views/index.haml")
    response.should have_selector("h2", :content => "Bar")
  end

  it "should link to the the meal titles" do
    render("/views/index.haml")
    response.should have_selector("a",
                                  :href => "/meals/2009/05/15",
                                  :content => "Bar")
  end

  it "should include a pretty date for each meal" do
    render("/views/index.haml")
    response.should have_selector(".meals", :content => "May 15")
  end

  it "should include a summary of the meals" do
    render("/views/index.haml")
    response.should have_selector("p", :content => "Bar summary")
  end

  it "should wikify the summary" do
    assigns[:meals][0]["summary"] = "Foo *bar* baz"
    render("/views/index.haml")
    response.should have_selector("p strong",
                                  :content => "bar")

  end

  it "should include a thumbnail image of the meal" do
    render("/views/index.haml")
    response.should have_selector("img",
                                  :src    => "/images/2009-05-15/image1.jpg",
                                  :width  => "200",
                                  :height => "150")
  end

  it "should suggest that the user read more..." do
    render("/views/index.haml")
    response.should have_selector(".meals a",
                                  :href => "/meals/2009/05/15",
                                  :content => "Read more…")
  end

  it "should include a comma separated list of menu items" do
    stub!(:recipe_link).
      and_return(%Q|<a href="/recipes/2009/05/15/recipe1">chips</a>|,
                 %Q|<a href="/recipes/2009/05/15/recipe2">salsa</a>|)

    assigns[:meals][0]["menu"] << "[recipe:2009/05/15/recipe1]"
    assigns[:meals][0]["menu"] << "[recipe:2009/05/15/recipe2]"

    render("/views/index.haml")
    response.should have_selector(".menu-items",
                                  :content => "chips, salsa")
  end

  it "should only include new recipe menu items" do
    stub!(:recipe_link).
      and_return(%Q|<a href="/recipes/2009/05/15/recipe1">chips</a>|)

    assigns[:meals][0]["menu"] << "[recipe:2009/05/14/recipe1]"
    assigns[:meals][0]["menu"] << "chili"
    assigns[:meals][0]["menu"] << "[recipe:2009/05/15/recipe2]"

    render("/views/index.haml")
    response.should have_selector(".menu-items",
                                  :content => "chips")
  end

  it "should not include a delimiter between \"Read more\" and new recipes when no new recipes" do
    render("/views/index.haml")
    response.should_not have_selector(".meals",
                                      :content => "|")

  end

  context "13 or more meals have been preared" do
    before(:each) do
      assigns[:meals] =
        [{ "_id"     => "2009-05-15",
           "date"    => "2009-05-15",
           "title"   => "Bar",
           "summary" => "Bar summary",
           "menu"    => [],
           "_attachments" => {"image1.jpg" => { }}
         }] * 10

      assigns[:older_meals] =
        [{ "_id"     => "2009-04-15",
           "date"    => "2009-04-15",
           "title"   => "Foo"
         }] * 3
    end
    it "should link to the next 3" do
      render("/views/index.haml")
      response.should have_selector("a",
                                    :href => "/meals/2009/04/15",
                                    :content => "Foo")
    end
  end
end
