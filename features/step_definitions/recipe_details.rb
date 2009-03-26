Given /^a recipe for Buttermilk Chocolate Chip Pancakes$/ do
  @date = Date.new(2009, 3, 24)
  @title = "Buttermilk Chocolate Chip Pancakes"
  @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

  RestClient.put "#{@@db}/#{@permalink}",
    { :title => @title,
      :date  => @date }.to_json,
    :content_type => 'application/json'
end

When /^I view the recipe$/ do
  visit("/recipes/#{@permalink}")
end

Then /^I should see an ingredient of "(.+)"$/ do |ingredient|
  response.should contain(ingredient)
end
