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
      :menu        => [],
      :published   => true,
      :_attachments => { "meal#{i}.jpg" => {
        :data => "R0lGODlhAQABAID/AMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAEBMgA7",
        :content_type => "image/gif"}
      }
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
      ],
      :type => 'Recipe',
      :published => true
    }

    RestClient.put "#{@@db}/#{permalink}",
      recipe.to_json,
      :content_type => 'application/json'

    # Update the meal to include the recipe in the menu
    meal['menu'] << "[recipe:#{permalink.gsub(/-/, '/')}]"
    RestClient.put "#{@@db}/#{meal['_id']}",
      meal.to_json,
      :content_type => 'application/json'

    memo + [permalink]
  end
end

Given /^the first 5 recipes are Italian$/ do
  @recipe_ids[0...5].each do |recipe_id|
    data = RestClient.get "#{@@db}/#{recipe_id}"
    recipe = JSON.parse(data)

    recipe['tag_names'] = ['italian']

    RestClient.put "#{@@db}/#{recipe['_id']}",
      recipe.to_json,
      :content_type => 'application/json'
  end
end

Given /^the second 10 recipes are Vegetarian$/ do
  @recipe_ids[5...15].each do |recipe_id|
    data = RestClient.get "#{@@db}/#{recipe_id}"
    recipe = JSON.parse(data)

    recipe['tag_names'] = ['vegetarian']

    RestClient.put "#{@@db}/#{recipe['_id']}",
      recipe.to_json,
      :content_type => 'application/json'
  end
end

When /^I view the site.s homepage$/ do
  visit('/')
  last_response.should be_ok
end

Then /^I should see the 10 most recent meals prominently displayed$/ do
  response_body.should have_selector("h2", :count => 10)
  response_body.should have_selector("h2", :content => "Meal 0")
  response_body.should have_selector("h2", :content => "Meal 9")
  response_body.should_not have_selector("h2", :content => "Meal 10")
end

Then /^the prominently displayed meals should include a thumbnail image$/ do
  response_body.should have_selector(".meals img", :count => 10)
end

Then /^the prominently displayed meals should include the recipe titles$/ do
  response_body.should have_selector(".menu-items",
                                     :content => "Recipe for Meal 1")
end

When /^I click on the first meal$/ do
  click_link "Meal 0"
end

When /^I click the site logo$/ do
  click_link "/"
end

Then /^I should see the meal page$/ do
  response_body.should have_selector("h1",
                                     :content => "Meal 0")
end

Then /^the (\w+) category should be highlighted$/ do |category|
  response_body.should have_selector("a",
                                     :class => "active",
                                     :content => category)
end

When /^I click on the recipe in the menu$/ do
  click_link "Recipe for Meal 0"
end

When /^I click the (\w+) category$/ do |category|
  click_link category
end

When /^I click the recipe link under the 6th meal$/ do
  click_link "Recipe for Meal 5"
end

When /^I fill out the form with effusive praise$/ do
  fill_in "Name",    :with => "Bob"
  fill_in "Email",   :with => "foo@example.org"
  fill_in "Subject", :with => "Your site is awesome!"
  fill_in "Message", :with => "The recipes are delicious and your use of CouchDB is impressive."
end

When /^I click the "([^\"]*)" button$/ do |button_text|
  # Don't send email in tests
  Pony.stub!(:mail)
  click_button button_text
end

Then /^I should see the recipe page$/ do
  response_body.should have_selector("h1",
                                     :content => "Recipe for Meal ")
end

Then /^I should see 5 Italian recipes$/ do
  # 5 result rows + 1 header row
  response_body.should have_selector("tr",
                                     :count => 6)
end

Then /^I should see the homepage$/ do
  response.should have_selector(".meals h2", :count => 10)
end

Then /^I should see no more pages of results$/ do
  response.should have_selector(".inactive", :content => "Next »")
end

Then /^I should see a feedback form$/ do
  response.should have_selector("h1", :content => "Feedback")
  response.should have_selector("form")
end

Then /^I should see a thank you note$/ do
  response.should have_selector("h1", :content => "Thank You")
end

Then /^I should see a subject of "([^\"]*)"$/ do |subject|
  response.should have_selector("input",
                                :value => subject)
end
