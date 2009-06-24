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
    :summary => "This is #{keyword}",
    :preparations => [
      { 'ingredient' => { 'name' => 'ingredient' } }
    ]
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
    :instructions => instructions,
    :preparations => [
      { 'ingredient' => { 'name' => 'ingredient' } }
    ]
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
    :preparations => [
      { 'ingredient' => { 'name' => 'ingredient' } }
    ]
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

  (1..count.to_i).each do |i|
    permalink = "id-#{i}-#{keyword.gsub(/\W/, '-')}"

    recipe = {
      :title => "#{keyword} recipe #{i}",
      :date  => date,
      :preparations => [
        { 'ingredient' => { 'name' => 'ingredient' } }
      ],
      :tag_names => [keyword.downcase]
    }

    RestClient.put "#{@@db}/#{permalink}",
      recipe.to_json,
      :content_type => 'application/json'
  end
end

Given /^(\d+) "([^\"]*)" recipes with ascending names, dates, preparation times, and number of ingredients$/ do |count, keyword|
  date = Date.new(2008, 4, 28)

  (1..count.to_i).each do |i|
    permalink = "id-#{i}-#{keyword.gsub(/\W/, '-')}"

    recipe = {
      :title     => "#{keyword} recipe #{i}",
      :date      => date + i,
      :prep_time => i,
      :preparations =>
        (1..count.to_i).
        map {|j| { :ingredient => { :name => "ingredient #{j}"}} }
    }

    RestClient.put "#{@@db}/#{permalink}",
      recipe.to_json,
      :content_type => 'application/json'
  end
end

Given /^(\d+) "([^\"]*)" meals?$/ do |count, keyword|
  date = Date.new(2008, 5, 12)

  (1..count.to_i).each do |i|
    permalink = "id-#{date.to_s}"

    meal = {
      :title       => "#{keyword} meal #{i}",
      :date        => date + i,
      :serves      => i,
      :summary     => "#{keyword} summary",
      :description => "#{keyword} description"
    }

    RestClient.put "#{@@db}/#{permalink}",
      meal.to_json,
      :content_type => 'application/json'
  end
end

Given /^1 "([^\"]*)" document with the word "([^\"]*)" in it$/ do |arg1, arg2|
  permalink = "id-#{arg1.gsub(/\W/, '-')}"

  doc = {
    :title   => arg1,
    :content => arg2
  }

  RestClient.put "#{@@db}/#{permalink}",
    doc.to_json,
    :content_type => 'application/json'
end


Given /^a ([.\d]+) second wait/ do |seconds|
  sleep seconds.to_f
end

When /^I search for "(.*)"$/ do |keyword|
  @query = "/recipes/search?q=#{keyword}"
  visit(@query)
end

When /^I search titles for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=title:#{keyword}")
end

When /^I search ingredients for "(.+)"$/ do |keyword|
  visit("/recipes/search?q=ingredient:#{keyword}")
end

When /^I search for an invalid lucene search term like "([^\"]*)"$/ do |keyword|
  visit("/recipes/search?q=#{keyword}")
end

When /^I click page (\d+)$/ do |page|
  click_link(page)
end

When /^I click the (.+) page$/ do |link_text|
  click_link(link_text)
end

When /^I visit page \"?(.+?)\"?$/ do |page|
  visit(@query + "&page=#{page}")
end

When /^I click the "([^\"]*)" column header$/ do |link|
  click_link("sort-by-#{link.downcase()}")
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
  response.should have_selector("table td a", :count => count.to_i)
end

Then /^I should see (\d) pages of results$/ do |pages|
  response.should have_selector(".pagination a", :content => pages)
end

Then /^I should not be able to go to a (.+) page$/ do |link_text|
  response.should have_selector(".pagination span",
                                :content => link_text.capitalize())
end

Then /^I should be able to go to a (.+) page$/ do |link_text|
  response.should have_selector(".pagination a",
                                :content => link_text.capitalize())
end

Then /^I should see page (.+)$/ do |page|
  @page = page.to_i
  response.should have_selector(".pagination span.current",
                                :content => page)
end

Then /^the results should be ordered by name in ascending order$/ do
  response.should have_selector("tr:nth-child(2) a",
                                :content => "delicious recipe 1")
  response.should have_selector("tr:nth-child(3) a",
                                :content => "delicious recipe 10")
end

Then /^the results should be ordered by name in descending order$/ do
  if @page == 2
    response.should have_selector("tr:nth-child(2) a",
                                  :content => "delicious recipe 36")
    response.should have_selector("tr:nth-child(3) a",
                                  :content => "delicious recipe 35")
  else
    response.should have_selector("tr:nth-child(2) a",
                                  :content => "delicious recipe 9")
    response.should have_selector("tr:nth-child(3) a",
                                  :content => "delicious recipe 8")
  end
end

Then /^the results should be ordered by date in descending order$/ do
    response.should have_selector("tr:nth-child(2) .date",
                                  :content => "2008-06-17")
    response.should have_selector("tr:nth-child(3) .date",
                                  :content => "2008-06-16")
end

Then /^the results should be ordered by date in ascending order$/ do
    response.should have_selector("tr:nth-child(2) .date",
                                  :content => "2008-04-29")
    response.should have_selector("tr:nth-child(3) .date",
                                  :content => "2008-04-30")
end

Then /^the results should be ordered by preparation time in ascending order$/ do
    response.should have_selector("tr:nth-child(2) .prep",
                                  :content => "1")
    response.should have_selector("tr:nth-child(3) .prep",
                                  :content => "2")
end

Then /^the results should be ordered by the number of ingredients in ascending order$/ do
    response.should have_selector("tr:nth-child(2) .ingredients",
                                  :content => "ingredient 1")
    response.should have_selector("tr:nth-child(3) .ingredients",
                                  :content => "ingredient 1, ingredient 2")
end

Then /^I should see no results$/ do
  response.should have_selector("p.no-results")
end

Then /^no result headings$/ do
  response.should_not have_selector("th")
end

Then /^I should see an empty query string$/ do
  response.should have_selector("input[@name=query][@value='']")
end
