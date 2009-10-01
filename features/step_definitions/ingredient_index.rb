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

