When /^I visit the mini\-calendar$/ do
  visit("/mini/")
end

When /^I click on the link to the previous month$/ do
  click_link "<"
end

Then /^I should see the calendar for (.+)$/ do |date|
  response.should have_selector("h1", :content => date)
end

Then /^there should be (\d) links to meals$/ do |count|
  response.should have_selector("td a", :count => count.to_i)
end

Then /^there should not be a link to the next month$/ do
  response.should_not have_selector("a", :content => ">")
end

Then /^there should be no links to meals$/ do
  response.should_not have_selector("table a")
end

Then /^there should be a link to the next month$/ do
  response.should have_selector("a", :content => ">")
end

Then /^there should not be a link to the previous month$/ do
  response.should_not have_selector("a", :content => "<")
end
