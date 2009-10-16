Feature: Alternate preparations for recipes

  As a user curious about a recipe
  I want to see a list of similar recipes
  So that I can find a recipe that matches my tastes or ingredients on hand

  Scenario: No alternate preparation

    Given a "pancake" recipe with "buttermilk"
    And no other recipes
    When I visit the recipe with "buttermilk" in it
    Then I should see no alternate preparations

  Scenario: Alternate preparation

    Given a "Hearty Pancake" recipe with "wheat germ"
    And a "Buttermilk Pancake" recipe with "buttermilk"
    And a "Pancake" recipe with "chocolate chips"
    And the three pancake recipes are alternate preparations of each other
    And I visit the "Hearty Pancake" recipe
    Then I should see a link to the "Buttermilk Pancake" recipe
    And I should see a link to the "Pancake" recipe
    And I should not see a link to the "Hearty Pancake" recipe
    When I click the "Buttermilk Pancake" link
    Then I should see a link to the "Hearty Pancake" recipe
    And I should see a link to the "Pancake" recipe
    And I should not see a link to the "Buttermilk Pancake" recipe
