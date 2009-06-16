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
  end

  it "should link to the meal titles" do
    render("/views/index.haml")
    response.should have_selector("h2", :content => "Bar")
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

  it "should include a comma separated list of menu items" do
    assigns[:meals][0]["menu"] << "chips"
    assigns[:meals][0]["menu"] << "salsa"
    render("/views/index.haml")
    response.should have_selector(".menu-items",
                                  :content => "chips, salsa")
  end

  it "should wikify menu items" do
    assigns[:meals][0]["menu"] << "_really_ hot salsa"
    render("/views/index.haml")
    response.should have_selector(".menu-items em",
                                  :content => "really")
  end
end
