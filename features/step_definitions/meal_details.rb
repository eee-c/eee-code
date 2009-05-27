Given /^a "([^\"]*)" meal enjoyed in (.+)$/ do |title, date_str|
  date = (date_str =~ /^\s*(\d+)\s*$/) ?
    Date.new($1.to_i, 5, 13) : Date.parse(date_str)

  permalink = "id-#{date.to_s}"

  meal = {
    :title       => title,
    :date        => date.to_s,
    :serves      => 4,
    :summary     => "meal summary",
    :description => "meal description",
    :type        => "Meal",
    :menu        => []
  }

  RestClient.put "#{@@db}/#{permalink}",
    meal.to_json,
    :content_type => 'application/json'
end

When /^I view the list of meals prepared in 2009$/ do
  visit("/meals/2009")
  response.status.should == 200
end

When /^I view the list of meals prepared in May of 2009$/ do
  visit("/meals/2009/05")
  response.status.should == 200
end

When /^I follow the link to the list of meals in (.+)$/ do |date|
  click_link date
end

Then /^the "([^\"]*)" meal should be included in the list$/ do |title|
  response.should have_selector("li a", :content => title)
end

Then /^the "([^\"]*)" meal should not be included in the list$/ do |title|
  response.should_not have_selector("a", :content => title)
end

Then /^I should see the "([^\"]*)" meal among the meals of this month$/ do |title|
  response.should have_selector("h2", :content => title)
end

Then /^I should not see the "([^\"]*)" meal among the meals of this month$/ do |title|
  response.should_not have_selector("h2", :content => title)
end

Then /^I should see a link to (.+)$/ do |date|
  response.should have_selector("a", :content => date)
end

Then /^I should not see a link to (.+)$/ do |date|
  response.should_not have_selector("a", :content => date)
end
