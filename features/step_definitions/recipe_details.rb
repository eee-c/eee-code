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

Given /^a recipe for Chicken Noodle Soup$/ do
  @date = Date.new(2009, 4, 1)
  @title = "Chicken Noodle Soup"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  recipe = {
    :title => @title,
    :date  => @date,
    :tools => [
       {
           "title"        => "Bowl",
           "asin"         => nil,
           "amazon_title" => nil
       },
       {
           "title"        => "Colander",
           "asin"         => nil,
           "amazon_title" => nil
       },
       {
           "title"        => "Cutting Board",
           "asin"         => nil,
           "amazon_title" => nil
       },
       {
           "title"        => "Pot",
           "asin"         => nil,
           "amazon_title" => nil
       },
       {
           "title"        => "Skimmer",
           "asin"         => nil,
           "amazon_title" => nil
       },
    ]
  }

  RestClient.put "#{@@db}/#{@permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a recipe for Mango and Tomato Salad$/ do
  @date = Date.new(2009, 4, 2)
  @title = "Mango and Tomato Salad"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  recipe = {
    :title => @title,
    :date  => @date,
    :tag_names => [ "vegetarian", "salad" ]
  }

  RestClient.put "#{@@db}/#{@permalink}",
    recipe.to_json,
    :content_type => 'application/json'
end

Given /^a recipe for Curried Shrimp$/ do
  @date = Date.new(2009, 4, 2)
  @title = "Mango and Tomato Salad"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  @summary = "This dish is *yummy*."
  @instructions = <<_EOM
While the shrimp are defrosting, we chop the vegetables.

The onion and the garlic are finely chopped, keeping them separate on the large cutting board.
_EOM

  recipe = {
    :title        => @title,
    :date         => @date,
    :summary      => @summary,
    :instructions => @instructions
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
  response.should contain("Preparation Time: 15 minutes")
end

Then /^I should see that it requires 5 hours of non\-active cook time$/ do
  response.should contain("Inactive Time: 5 hours")
end

Then /^I should see that it requires (.+) to prepare$/ do |tool_list|
  tools = tool_list.
    split(/\s*(,|and)\s*/).
    reject{|str| str == "," || str == "and"}
  tools.each do |tool|
    response.should contain(tool.sub(/an? /, ''))
  end
end

Then /^I should see the site\-wide categories of (.+)$/ do |category_list|
  categories = category_list.
    split(/\s*(,|and)\s*/).
    reject{|str| str == "," || str == "and"}
  response.should have_selector("#eee-categories") do |list|
    categories.each do |category|
      response.should have_selector("a", :content => category)
    end
  end
end

Then /^the Salad and Vegetarian categories should be active$/ do
  response.should have_selector("a", :class => "active", :content => "Salad")
  response.should have_selector("a", :class => "active", :content => "Vegetarian")
  response.should_not have_selector("a", :class => "active", :content => "Fish")
end
