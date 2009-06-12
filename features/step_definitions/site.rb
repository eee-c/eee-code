Given /^(\d+) yummy meals$/ do |count|
  start_date = Date.new(2009, 6, 11)

  @meal_ids = (0...count.to_i).inject([]) do |memo, i|
    date = start_date - (i * 10)

    meal = {
      :title       => "Meal #{i}",
      :date        => date.to_s,
      :serves      => 4,
      :summary     => "meal summary",
      :description => "meal description",
      :type        => "Meal",
      :menu        => []
    }

    RestClient.put "#{@@db}/#{date.to_s}",
      meal.to_json,
      :content_type => 'application/json'

    memo + [date.to_s]
  end
end

Given /^1 delicious recipe for each meal$/ do
  @recipe_ids = @meal_ids.inject([]) do |memo, meal_id|
    data = RestClient.get "#{@@db}/#{meal_id}"
    meal = JSON.parse(data)

    permalink = meal['date'] + "-recipe"

    recipe = {
      :title => "Recipe for #{meal['title']}",
      :date  => meal['date'],
      :preparations => [
        { 'ingredient' => { 'name' => 'ingredient' } }
      ]
    }

    RestClient.put "#{@@db}/#{permalink}",
      recipe.to_json,
      :content_type => 'application/json'

    # Update the meal to include the recipe in the menu
    meal['menu'] << "[recipe:#{permalink.gsub(/-/, '/')}"
    RestClient.put "#{@@db}/#{meal['_id']}",
      meal.to_json,
      :content_type => 'application/json'

    memo + [permalink]
  end
end

Given /^the first 5 recipes are Italian$/ do
  #pending
  puts @recipe_ids.pretty_inspect
end

