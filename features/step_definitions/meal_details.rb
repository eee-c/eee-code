Given /^a "([^\"]*)" meal enjoyed in (\d+)$/ do |title, year|
  date = Date.new(year.to_i, 5, 13)

  permalink = "id-#{date.to_s}"

  meal = {
    :title       => title,
    :date        => date,
    :serves      => 4,
    :summary     => "meal summary",
    :description => "meal description"
  }

  RestClient.put "#{@@db}/#{permalink}",
    meal.to_json,
    :content_type => 'application/json'
end

When /^I view the list of meals prepared in 2009$/ do
  visit("/meals/2009")
  response.status.should == 200
end

Then /^the "([^\"]*)" meal should be included in the list$/ do |title|
  response.should have_selector("li a", :content => title)
end

Then /^the "([^\"]*)" meal should not be included in the list$/ do |title|
  response.should_not have_selector("a", :content => title)
end
