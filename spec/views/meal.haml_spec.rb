require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "meal.haml" do
  before(:each) do
    @title  = "Meal Title"
    @summary = "Meal Summary"
    @description = "Meal Description"
    @year = 2009
    @month = 5

    assigns[:meal] = @meal = {
      'date'        => "%d-%02d-31" % [@year, @month],
      'title'       => @title,
      'summary'     => @summary,
      'description' => @description,
      'menu'        => ["Peanut Butter and Jelly Sandwich"]
    }

    assigns[:meals_by_date] = [{ "key" => "2009-05-15",
                                 "value" => ['2009-05-15', "Foo"] },
                               { "key" => "2009-05-31",
                                 "value" => ["2009-05-31", "Bar"] }]

    assigns[:recipes] = []

    assigns[:url] = "http://example.org/recipe-1"
  end

  it "should display a breadcrumb link to the other meals in this year" do
    render("/views/meal.haml")
    response.should have_selector(".breadcrumbs a",
                                  :href => "/meals/#{@year}")
  end

  it "should display a breadcrumb link to the other meals in this month" do
    render("/views/meal.haml")
    response.should have_selector(".breadcrumbs a",
                                  :href => "/meals/#{@year}/#{"%02d" % @month}")
  end

  it "should display the meal's title" do
    render("/views/meal.haml")
    response.should have_selector("h1", :content => @title)
  end

  it "should link to previous meal" do
    render("/views/meal.haml")
    response.should have_selector("a",
                                  :href => "/meals/2009/05/15",
                                  :content => "May 15, 2009")
  end

  it "should link to previous meal title" do
    render("/views/meal.haml")
    response.should have_selector("a",
                                  :href => "/meals/2009/05/15",
                                  :content => "Foo")
  end

  it "should display the meal's summary" do
    render("/views/meal.haml")
    response.should have_selector("#summary", :content => @summary)
  end

  it "should wikify the meal's summary" do
    assigns[:meal]['summary'] = "paragraph 1\n\nparagraph 2"
    render("/views/meal.haml")
    response.should have_selector("#summary p", :content => "paragraph 1")
  end

  it "should include the menu after the summary" do
    render("/views/meal.haml")
    response.should have_selector("#summary + ul#menu li",
                                  :content => "Peanut Butter and Jelly Sandwich")
  end

  it "should wikify the menu items" do
    assigns[:meal]['menu'] << "foo *bar* baz"
    render("/views/meal.haml")
    response.should have_selector("ul#menu li strong",
                                  :content => "bar")
  end

  it "should display a description of the meal after the menu" do
    render("/views/meal.haml")
    response.should have_selector("#menu + #description",
                                  :content => @description)
  end

  it "should wikify the meal's description" do
    assigns[:meal]['description'] = "paragraph 1\n\nparagraph 2"
    render("/views/meal.haml")
    response.should have_selector("#description p", :content => "paragraph 1")
  end

  it "should link to the feedback form" do
    render("/views/meal.haml")
    response.should have_selector("a",
                                  :content => "Send us feedback on this meal")
  end

  it "should include the recipe's URL in the feedback link" do
    render("/views/meal.haml")
    response.should have_selector("a",
                                  :href => "/feedback?url=http%3A%2F%2Fexample.org%2Frecipe-1&subject=%5BMeal%5D+Meal+Title",
                                  :content => "Send us feedback on this meal")
  end
end
