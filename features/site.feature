Feature: Site

  So that I may explore many wonderful recipes and see the meals in which they were served
  As someone interested in cooking
  I want to be able to easily explore this awesome site

  Scenario: Quickly scanning meals and recipes accessible from the home page

    Given 25 yummy meals
    And 1 delicious recipe for each meal
    And the first 5 recipes are Italian
    And the second 10 recipes are Vegetarian
    When I view the site's homepage
    Then I should see the 10 most recent meals prominently displayed
    And the prominently displayed meals should include a thumbnail image
    And the prominently displayed meals should include the recipe titles
    When I click on the first meal
    Then I should see the meal page
    And the Italian category should be highlighted
    When I click on the recipe in the menu
    Then I should see the recipe page
    And the Italian category should be highlighted
    When I click on the Italian category
    Then I should see 5 Italian recipes
    When I click the site logo
    Then I should see the homepage
    When I click the recipe link under the 6th meal
    Then I should see the recipe page
    And the Vegetarian category should be highlighted

  Scenario: Exploring food categories (e.g. Italian) from the homepage

    Given 50 Italian recipes
    And 10 Breakfast recipes
    When I view the site's homepage
    And I click the Italian category
    Then I should see 20 recipes
    And links to 2 other pages
    When I click the site logo
    Then I should see the homepage
    And I click the Breakfast category
    Then I should see 10 recipes
    And links to 0 other pages

  Scenario: Give feedback to the authors of this fantastic site

    When I view the site's homepage
    And I click "Send us comments"
    Then I should see a feedback form
    When I fill out the form with effusive praise
    And click the submit button
    Then I should see a thank you note

  Scenario: Give feedback to the authors on a yummy meal

  Scenario: Give feedback to the authors on a delicious recipe
