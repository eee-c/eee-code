Given /^a "pancake" recipe with "chocolate chips" in it$/ do
  date = Date.new(2009, 4, 12)
  title = "Buttermilk Chocolate Chip Pancakes"
  @pancake_permalink = date.to_s + "-" + title.downcase.gsub(/\W/, '-')

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

  RestClient.put "#{@@db}/#{@pancake_permalink}",
    @pancake_recipe.to_json,
    :content_type => 'application/json'
end

Given /^a "french toast" recipe with "eggs" in it$/ do
  @date = Date.new(2009, 4, 12)
  @title = "French Toast"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  recipe = {
    :title => @title,
    :date  => @date,
    :preparations => [
      {
        'quantity' => '1',
        'ingredient' => { 'name' => 'egg'}
      }
    ]
  }

  RestClient.put "#{@@db}/#{@permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

When /^I search for "chocolate"$/ do
  sleep 5
  visit("/recipes/search?q=chocolate")
end

Then /^I should see the "pancake" recipe in the search results$/ do
  response.should have_selector("a", :href => "/recipes/#{@pancake_permalink}")
end
