Given /^a "(.+)" recipe with "chocolate chips" in it$/ do |title|
  date = Date.new(2009, 4, 12)
  permalink = "id-#{title}"

  @pancake_recipe = {
    :title => title,
    :date  => date,
    :preparations => [
      {
        'brand' => 'Nestle Tollhouse',
        'ingredient' => {
          'name' => 'chocolate chips'
        }
      }
    ]
  }

  RestClient.put "#{@@db}/#{permalink}",
    @pancake_recipe.to_json,
    :content_type => 'application/json'
end

Given /^a "(.+)" recipe with "eggs" in it$/ do |title|
  date = Date.new(2009, 4, 12)
  permalink = "id-#{title.gsub(/\W/, '-')}"

  recipe = {
    :title => title,
    :date  => date,
    :preparations => [
      {
        'quantity' => '1',
        'ingredient' => { 'name' => 'egg'}
      }
    ]
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a "(.+)" recipe with a "(.+)" summary$/ do |title, keyword|
  date = Date.new(2009, 4, 12)
  permalink = "id-#{title.gsub(/\W/, '-')}"

  recipe = {
    :title => title,
    :date  => date,
    :summary => "This is #{keyword}"
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a (\d+) second wait to allow the search index to be updated$/ do |seconds|
  sleep seconds.to_i
end

When /^I search for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=#{keyword}")
end

Then /^I should see the "(.+)" recipe in the search results$/ do |title|
  response.should have_selector("a",
                                :href => "/recipes/id-#{title}",
                                :content => title)
end

Then /^I should not see the "(.+)" recipe in the search results$/ do |title|
  response.should_not have_selector("a", :content => title)
end
