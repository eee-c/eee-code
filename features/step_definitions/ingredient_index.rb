Given /^a "([^\"]*)" recipe with "([^\"]*)" and "([^\"]*)"$/ do |title, ing1, ing2|
  date = Date.new(2009, 9, 30)
  permalink = date.to_s + "-" + title.downcase.gsub(/\W/, '-')

  @permalink_identified_by ||= { }
  @permalink_identified_by[title] = permalink

  recipe = {
    :title => title,
    :type  => 'Recipe',
    :published => true,
    :date  => date,
    :preparations => [{'ingredient' => {'name' => ing1}},
                      {'ingredient' => {'name' => ing2}}]
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

When /^I visit the ingredients page$/ do
  visit "/ingredients"
end

Then /^I should see the "([^\"]*)" ingredient$/ do |ingredient|
  response.should have_selector(".ingredient",
                                :content => ingredient)
end

Then /^"([^\"]*)" recipes should include "([^\"]*)" and "([^\"]*)"$/ do |ingredient, arg2, arg3|
  response.should have_selector(".recipes") do |span|
    span.should have_selector("a", :content => arg2)
    span.should have_selector("a", :content => arg3)
  end
end

Then /^"([^\"]*)" recipes should include only "([^\"]*)"$/ do |ingredient, recipe|
  response.should have_xpath("//p[contains(span, '#{ingredient}')]/span[contains(., '#{recipe}')]")
  response.should have_xpath("//p[contains(span, '#{ingredient}')]/span[count(a)=1]")
end
