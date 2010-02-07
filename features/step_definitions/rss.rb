When /^I access the meal RSS feed$/ do
  visit('/main.rss')
  last_response.should be_ok
end

When /^I access the recipe RSS feed$/ do
  visit('/recipes.rss')
  last_response.should be_ok
end

Then /^I should see the 10 most recent meals$/ do
  response_body.
    should have_selector("channel > item > title",
                         :count => 10)
  response_body.
    should have_selector("channel > item > title",
                         :content => "Meal 0")
end

Then /^I should see the summary of each meal$/ do
  response_body.
    should have_selector("channel > item > description",
                         :content => "meal summary")
end

Then /^I should see a meal link$/ do
  response_body.
    should contain('http://www.eeecooks.com/meals/2009/06/11')
    # should have_selector('link',
    #                      :content => 'http://www.eeecooks.com/meals/2009/06/11')
end

Then /^I should see a meal published date$/ do
  response_body.
    should contain("Thu, 11 Jun 2009")
end

Then /^I should see the 10 most recent recipes$/ do
  response_body.
    should have_selector("channel > item > title",
                         :count => 10)
  response_body.
    should have_selector("channel > item > title",
                         :content => "delicious, easy to prepare")
end

Then /^I should see the summary of each recipe$/ do
  response_body.
    should have_selector("channel > item > description",
                         :content => "recipe summary")
end
