Feature: RSS

  So that I tell my user when there are updates to this great cooking site
  As an RSS bot
  I want to be able to consume your RSS

  Scenario: Meal RSS

    Given 20 yummy meals
    When I access the meal RSS feed
    Then I should see the 10 most recent meals
    And I should see the summary of each meal

  Scenario: Recipe RSS

    Given 20 delicious, easy to prepare recipes
    When I access the recipe RSS feed
    Then I should see the 10 most recent recipes
    And I should see the summary of each recipe
