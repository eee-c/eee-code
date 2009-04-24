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

Given /^a "(.+)" recipe with instructions "(.+)"$/ do |title, instructions|
  date = Date.new(2009, 4, 16)
  permalink = "id-#{title.gsub(/\W/, '-')}"

  recipe = {
    :title => title,
    :date  => date,
    :instructions => instructions
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a "(.+)" recipe$/ do |title|
  date = Date.new(2009, 4, 19)
  permalink = "id-#{title.gsub(/\W/, '-')}"

  recipe = {
    :title => title,
    :date  => date,
  }

  RestClient.put "#{@@db}/#{permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end


Given /^a "(.+)" recipe with "(.+)" in it and a summary of "(.+)"$/ do |title, ingredient, summary|
  date = Date.new(2009, 4, 21)
  permalink = "id-#{title.gsub(/\W/, '-')}"

  @pancake_recipe = {
    :title => title,
    :date  => date,
    :summary => summary,
    :preparations => [
      {
        'ingredient' => {
          'name' => ingredient
        }
      }
    ]
  }

  RestClient.put "#{@@db}/#{permalink}",
    @pancake_recipe.to_json,
    :content_type => 'application/json'
end

Given /^(\d+) (.+) recipes$/ do |count, keyword|
  date = Date.new(2009, 4, 22)

  (0..count.to_i).each do |i|
    permalink = "id-#{i}-#{keyword.gsub(/\W/, '-')}"

    @pancake_recipe = {
      :title => "#{keyword} recipe #{i}",
      :date  => date
    }

    RestClient.put "#{@@db}/#{permalink}",
    @pancake_recipe.to_json,
    :content_type => 'application/json'
  end
end

Given /^a ([.\d]+) second wait/ do |seconds|
  sleep seconds.to_f
end

When /^I search for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=#{keyword}")
end

When /^I search titles for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=title:#{keyword}")
end

When /^I search ingredients for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=ingredient:#{keyword}")
end

Then /^I should see the "(.+)" recipe in the search results$/ do |title|
  response.should have_selector("a",
                                :href => "/recipes/id-#{title.gsub(/\W/, '-')}",
                                :content => title)
end

Then /^I should not see the "(.+)" recipe in the search results$/ do |title|
  response.should_not have_selector("a", :content => title)
end

Then /^I should see (\d+) results$/ do |count|
  response.should have_selector("table a", :count => count.to_i)
end

Then /^I should see 3 pages of results$/ do
  response.should have_selector(".pagination a", :content => "3")
end
