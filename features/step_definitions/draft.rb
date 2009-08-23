Given /^"([^\"]*)", (\w+) on ([-\d]+)$/ do |title, status, date_str|
  date = Date.parse(date_str)
  recipe_permalink = date.to_s + "-" + title.downcase.gsub(/[#\W]+/, '-')

  var_name = '@' + title.downcase.gsub(/[#\W]+/, '_') + '_permalink'
  instance_variable_set(var_name.to_sym, recipe_permalink)

  recipe = {
    :title        => title,
    :date         => date,
    :summary      => "#{title} summary",
    :instructions => "#{title} instructions",
    :published    => status == 'published',
    :type => "Recipe"
  }

  RestClient.put "#{@@db}/#{recipe_permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

When /^I show "Recipe #1"$/ do
  visit("/recipes/#{@recipe_1_permalink}")
end

When /^I am asked for the next recipe$/ do
  click_link "Recipe #"
end

When /^I show all recipes via search$/ do
  sleep 0.5
  visit("/recipes/search?q=")
end

Then /^there should be no link to "([^\"]*)"$/ do |title|
  response.should_not have_selector("a", :content => title)
end

Then /^"([^\"]*)" should be shown$/ do |title|
  response.should have_selector("h1", :content => title)
end

Then /^there should be no next link$/ do
  response.should_not have_selector("a", :content => "Recipe #4")
end

Then /^there should be a link to "([^\"]*)"$/ do |title|
  response.should have_selector("a", :content => title)
end

Then /^"([^\"]*)" should be included in the search results$/ do |recipes_str|
  recipes = recipes_str.split(/\s*and\s*/)
  recipes.each do |recipe|
    response.should have_selector("a", :content => recipe)
  end
end

Then /^"([^\"]*)" should not be included in the search results$/ do |recipes_str|
  recipes = recipes_str.split(/\s*and\s*/)
  recipes.each do |recipe|
    response.should_not have_selector("a", :content => recipe)
  end
end
