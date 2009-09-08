Given /^a "([^\"]*)" recipe (.*)with "([^\"]*)" in it$/ do |title, on, ingredient|
  date = (on == "") ? Date.new(2009, 9, 5) : Date.new(2000, 9, 5)
  permalink = date.to_s + "-" + title.downcase.gsub(/\W/, '-')

  @permalink_identified_by ||= { }
  @permalink_identified_by[ingredient] = permalink

  recipe = {
    :title => title,
    :date  => date,
    :preparations => [{'ingredient' => {'name' => ingredient}}]
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

When /^the "([^\"]*)" recipe is marked as update of the "([^\"]*)" recipe$/ do |arg1, arg2|
  update = {
    :type => "Update",
    :name => "buttermilk pancakes",
    :updates => [
      { :id => @permalink_identified_by[arg2] },
      { :id => @permalink_identified_by[arg1] }
    ]
  }

  RestClient.put "#{@@db}/buttermilk_pancake_updates",
    update.to_json,
    :content_type => 'application/json'
end

When /^I visit the recipe with "([^\"]*)" in it$/ do |ingredient|
  visit "/recipes/#{@permalink_identified_by[ingredient]}"
end

Then /^I should not see previous versions of the recipe$/ do
  response.should_not contain 'This is an update of a previous recipe'
end

Then /^I should not see updated versions of the recipe$/ do
  response.should_not contain 'This recipe has been updated'
end
