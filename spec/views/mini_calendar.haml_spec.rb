require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "mini_calendar.haml" do
  before(:each) do
    assigns[:month] = "2009-08"
    assigns[:meals_by_date]  = {"2009-08-08" => "Meal Title"}
    assigns[:count_by_month] = [{"key" => "2009-07", "value" => 3},
                                {"key" => "2009-08", "value" => 3}]
  end

  it "should show a human readable month and year" do
    render("views/mini_calendar.haml")
    response.should have_selector("h1", :content => "August 2009")
  end

  it "should show a human readable month and year for other months" do
    assigns[:month] = "2009-01"
    render("views/mini_calendar.haml")
    response.should have_selector("h1", :content => "January 2009")
  end

  it "should not include previous month's dates" do
    render("views/mini_calendar.haml")
    response.should_not have_selector("td#2009-07-31",
                                      :content => "31")
  end

  it "should have the first of the month in the first week" do
    render("views/mini_calendar.haml")
    response.should have_selector("tr.week1 td",
                                  :content => "1")
  end

  it "should have the last of the month" do
    render("views/mini_calendar.haml")
    response.should have_selector("td",
                                  :content => "31")
  end

  it "should not include next month's dates" do
    render("views/mini_calendar.haml")
    response.should_not have_selector("td#2009-09-01",
                                      :content => "1")
  end

  it "should link to meals this month" do
    render("views/mini_calendar.haml")
    response.should have_selector("td#2009-08-08 a",
                                  :href => "/meals/2009/08/08",
                                  :title => "Meal Title")
  end

  it "should link to the previous month" do
    render("views/mini_calendar.haml")
    response.should have_selector("a",
                                  :href => "/mini/2009/07")
  end

  it "should link to the previous month" do
    render("views/mini_calendar.haml")
    response.should have_selector("a",
                                  :href => "/mini/2009/07",
                                  :content => "<")
  end

  it "should not link to the next month" do
    render("views/mini_calendar.haml")
    response.should_not have_selector("a",
                                      :content => ">")
  end
  it "should the next month indicator should not be a link" do
    render("views/mini_calendar.haml")
    response.should have_selector(".next",
                                  :content => ">")
  end

  context "meals in next month, but not previous" do
    before(:each) do
      assigns[:count_by_month] = [{"key" => "2009-08", "value" => 3},
                                  {"key" => "2009-09", "value" => 3}]
    end
    it "should not link to the previous month" do
      render("views/mini_calendar.haml")
      response.should_not have_selector("a",
                                        :content => "<")
    end
    it "should have a previous month indicator that should not be a link" do
      render("views/mini_calendar.haml")
      response.should have_selector(".previous",
                                    :content => "<")
    end
    it "should link to the next month" do
      render("views/mini_calendar.haml")
      response.should have_selector("a",
                                    :href => "/mini/2009/09",
                                    :content => ">")
    end
  end
end
