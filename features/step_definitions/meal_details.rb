Given /^a "([^\"]*)" meal enjoyed in (\d+)$/ do |title, year|
  date = Date.new(year.to_i, 5, 13)

  permalink = "id-#{date.to_s}"

  meal = {
    :title       => title,
    :date        => date.to_s,
    :serves      => 4,
    :summary     => "meal summary",
    :description => "meal description",
    :type        => "Meal"
  }

  RestClient.put "#{@@db}/#{permalink}",
    meal.to_json,
    :content_type => 'application/json'
end

When /^I view the list of meals prepared in 2009$/ do
  visit("/meals/2009")
  response.status.should == 200
end

When /^I follow the link to the list of meals in 2008$/ do
  save_and_open_page
  click_link "2008"
end

Then /^the "([^\"]*)" meal should be included in the list$/ do |title|
  response.should have_selector("li a", :content => title)
end

Then /^the "([^\"]*)" meal should not be included in the list$/ do |title|
  response.should_not have_selector("a", :content => title)
end
