require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "meal_by_month.haml" do
  before(:each) do
    assigns[:meals] =
      [{ "_id"     => '2009-05-14',
         "date"    => '2009-05-14',
         "title"   => 'Meal 1',
         "summary" => 'Meal 1 Summary',
         "menu"    => [],
         "_attachments" => {"image1.jpg" => { }}
       },
       { "_id"     => '2009-05-15',
         "date"    => '2009-05-15',
         "title"   => 'Meal 2',
         "summary" => 'Meal 2 Summary',
         "menu"    => %w(foo bar baz),
         "_attachments" => {"image2.jpg" => { }}
       }]

    assigns[:year]  = 2009
    assigns[:month] = '05'
    assigns[:count_by_year] = [{"key" => "2009-04", "value" => 3},
                               {"key" => "2009-05", "value" => 3}]
  end

  it "should include each meal's title" do
    render("/views/meal_by_month.haml")
    response.should have_selector("h2", :content => "Meal 1")
  end

  it "should link to the meal" do
    render("/views/meal_by_month.haml")
    response.should have_selector("a", :href => "/meals/2009/05/14")
  end

  it "should include each meal's date in the title" do
    render("/views/meal_by_month.haml")
    response.should have_selector("h2", :content => "2009-05-14")
  end

  it "should include each meal's summary" do
    render("/views/meal_by_month.haml")
    response.should have_selector("p", :content => "Meal 2 Summary")
  end

  it "should include a thumbnail image of the meal" do
    render("/views/meal_by_month.haml")
    response.should have_selector("img",
                                  :src    => "/images/2009-05-14/image1.jpg",
                                  :width  => "200",
                                  :height => "150")
  end

  it "should include the menu items" do
    render("/views/meal_by_month.haml")
    response.should have_selector(".menu",
                                  :content => "foo, bar, baz")
  end

  it "should include recipe titles in the menu items" do
    assigns[:meals][0]["menu"] =
      [" Salad with [recipe:2009/05/23/lemon_dressing] "]

    self.stub!(:_db).and_return("")

    RestClient.
      stub!(:get).
      and_return('{"_id":"foo","title":"Lemon Dressing"}')

    render("/views/meal_by_month.haml")
    response.should have_selector(".menu",
                                  :content => "Salad with Lemon Dressing")
  end

end
