require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "index.haml" do
  before(:each) do
    assigns[:meals] = [{ "id" => "2009-05-15",
                         "date" => "2009-05-15",
                         "title" => "Bar",
                         "summary" => "Bar summary"}]
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
end
