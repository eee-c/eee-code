Given /^no other recipes$/ do
  # nop
end

Given /^the three pancake recipes are alternate preparations of each other$/ do
  alternates = {
    :type => "Alternative",
    :name => "pancakes",
    :recipes => [
      @permalink_identified_by['wheat germ'],
      @permalink_identified_by['buttermilk'],
      @permalink_identified_by['chocolate chips']
    ]
  }

  RestClient.put "#{@@db}/pancake_alternates",
    alternates.to_json,
    :content_type => 'application/json'
end

When /^I visit the "Hearty Pancake" recipe$/ do
  visit "/recipes/#{@permalink_identified_by['wheat germ']}"
end

Then /^I should see no alternate preparations$/ do
  response.should_not contain('Alternate Preparations')
end

Then /^I should see a link to the "([^\"]*)" recipe$/ do |title|
  response.should have_selector("a", :content => title)
end

Then /^I should not see a link to the "([^\"]*)" recipe$/ do |title|
  response.should_not have_selector("a", :content => title)
end
