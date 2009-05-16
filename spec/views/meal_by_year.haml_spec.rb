require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "meal.haml" do
  before(:each) do
    assigns[:meals] = {
      'rows' => [
        { "value" => [['2009-05-14', 'Meal 1']]},
        { "value" => [['2009-05-15', 'Meal 2']]},
      ]
    }
    assigns[:year] = 2009
  end

  it "should display a list of meals" do
    render("/views/meal_by_year.haml")
    response.should have_selector("ul li", :count => 2)
  end

  it "should link to meals" do
    render("/views/meal_by_year.haml")
    response.should have_selector("li a", :content => "Meal 1")
  end

  it "should include the year in the title" do
    render("/views/meal_by_year.haml")
    response.should have_selector("h1", :content => "Meals from 2009")
  end
end
