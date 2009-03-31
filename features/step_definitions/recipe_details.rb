Given /^a recipe for Buttermilk Chocolate Chip Pancakes$/ do
  @date = Date.new(2009, 3, 24)
  @title = "Buttermilk Chocolate Chip Pancakes"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  recipe = {
    :title => @title,
    :date  => @date,
    :preparations => [
      {
        'quantity' => 1,
        'unit'     => 'cup',
        'ingredient' => {
          'name' => 'flour',
          'kind' => 'all-purpose, unbleached'
        }
      },
      {
        'quantity' => '¼',
        'unit'     => 'teaspoons',
        'ingredient' => { 'name' => 'salt'}
      },
      {
        'brand' => 'Nestle Tollhouse',
        'ingredient' => {
          'name' => 'chocolate chips'
        }
      }
    ]
  }


  RestClient.put "#{@@db}/#{@permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a recipe for Crockpot Lentil Andouille Soup$/ do
  @date = Date.new(2009, 3, 24)
  @title = "Crockpot Lentil Andouille Soup"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  recipe = {
    :title         => @title,
    :date          => @date,
    :inactive_time => 300,
    :prep_time     => 15
  }

  RestClient.put "#{@@db}/#{@permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

When /^I view the recipe$/ do
  visit("/recipes/#{@permalink}")
end

Then /^I should see an ingredient of "(.+)"$/ do |ingredient|
  matcher = ingredient.
    gsub(/\s+/, "\\s+").
    gsub(/\(/, "\\(").
    gsub(/\)/, "\\)")
  response.should contain(Regexp.new(matcher))
end

Then /^I should see 15 minutes of prep time$/ do
  pending
end
