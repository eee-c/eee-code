require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "meal_by_month.haml" do
  before(:each) do
    assigns[:meals] = {
      'rows' => [
        { "value" => [['2009-05-14', 'Meal 1']]},
        { "value" => [['2009-05-15', 'Meal 2']]},
      ]
    }
    assigns[:year]  = 2009
    assigns[:month] = '05'
    assigns[:count_by_year] = [{"key" => "2009-04", "value" => 3},
                               {"key" => "2009-05", "value" => 3}]

  end

  it "should include each meal's title" do
    render("/views/meal_by_month.haml")
    response.should have_selector("h2", :content => "Meal 1")
  end
end
