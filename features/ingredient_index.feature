Feature: Ingredient index for recipes

  As a user curious about ingredients or recipes
  I want to see a list of ingredients
  So that I can see a sample of recipes in the cookbook using a particular ingredient

  Scenario: A couple of recipes sharing an ingredient

    Given a "Cookie" recipe with "butter" and "chocolate chips"
    And a "Pancake" recipe with "flour" and "chocolate chips"
    When I visit the ingredients page
    Then I should see the "chocolate chips" ingredient
    And "chocolate chips" recipes should include "Cookie" and "Pancake"
    And I should see the "flour" ingredient
    And "flour" recipes should include only "Pancake"

  Scenario: Scores of recipes sharing an ingredient

    Given 120 recipes with "butter"
    When I visit the ingredients page
    Then I should not see the "butter" ingredient
