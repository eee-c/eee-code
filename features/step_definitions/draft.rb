Given /^"([^\"]*)", (\w+) on ([-\d]+)$/ do |title, status, date_str|
  date = Date.parse(date_str)

  type = title.split.first
  permalink = date.to_s
  permalink += "-" + title.downcase.gsub(/[#\W]+/, '_') if type == 'Recipe'

  var_name = '@' + title.downcase.gsub(/[#\W]+/, '_') + '_permalink'
  instance_variable_set(var_name.to_sym, permalink)

  doc = {
    :title        => title,
    :date         => date,
    :summary      => "#{title} summary",
    :published    => status == 'published',
    :menu         => [],
    :type => type
  }

  RestClient.put "#{@@db}/#{permalink}",
    doc.to_json,
    :content_type => 'application/json'
end

When /^I show "Recipe #1"$/ do
  visit("/recipes/#{@recipe_1_permalink.gsub('-', '/')}")
end

When /^I show "Meal #1"$/ do
  visit("/meals/#{@meal_1_permalink.gsub(/-/, '/')}")
end

When /^I am asked for the next recipe$/ do
  click_link "next-recipe"
end

When /^I am asked for the next meal$/ do
  click_link "Meal #"
end

When /^I am asked for the list of meals in (.+)$/ do |date|
  visit("/meals/#{date.gsub(/-/, '/')}")
end

When /^I show all recipes via search$/ do
  sleep 0.5
  visit("/recipes/search?q=")
end

When /^I am asked for the homepage$/ do
  visit("/")
end

Then /^there should be no link to "([^\"]*)"$/ do |title|
  response_body.should_not have_selector("a", :content => title)
end

Then /^"([^\"]*)" should be shown$/ do |title|
  response_body.should have_selector("h1", :content => title)
end

Then /^there should be no next link$/ do
  response_body.should_not have_selector("a", :content => "Recipe #4")
end

Then /^there should be a link to "([^\"]*)"$/ do |title|
  response_body.should have_selector("a", :content => title)
end

Then /^"([^\"]*)" should be included in the search results$/ do |recipes_str|
  recipes = recipes_str.split(/\s*and\s*/)
  recipes.each do |recipe|
    response_body.should have_selector("a", :content => recipe)
  end
end

Then /^"([^\"]*)" should not be included in the search results$/ do |recipes_str|
  recipes = recipes_str.split(/\s*and\s*/)
  recipes.each do |recipe|
    response_body.should_not have_selector("a", :content => recipe)
  end
end

Then /^"([^\"]*)" should be included$/ do |titles_str|
  titles = titles_str.split(/\s*and\s*/)
  titles.each do |title|
    response_body.should have_selector("a", :content => title)
  end
end

Then /^"([^\"]*)" should not be included$/ do |titles_str|
  titles = titles_str.split(/\s*and\s*/)
  titles.each do |title|
    response_body.should_not have_selector("a", :content => title)
  end
end
