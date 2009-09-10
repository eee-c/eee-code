Feature: Updating recipes in our cookbook

  As an author
  I want to mark recipes as replacing old one
  So that I can record improvements and retain previous attempts for reference

  Scenario: No previous or next version of a recipe

    Given a "Buttermilk Pancake" recipe with "buttermilk" in it
    When I view the recipe
    Then I should not see previous versions of the recipe
    And I should not see updated versions of the recipe

  Scenario: A previous version of the recipe

    Given a "Buttermilk Pancake" recipe with "buttermilk" in it
    And a "Buttermilk Pancake" recipe on another day with "lowfat milk" in it
    When the "buttermilk" recipe is marked as update of the "lowfat milk" recipe
    And I visit the recipe with "buttermilk" in it
    Then I should see that the recipe is an update to the recipe with "lowfat milk" in it
    And I should not see updated versions of the recipe
    When I visit the recipe with "lowfat milk" in it
    Then I should see that the recipe was updated by the recipe with "buttermilk" in it
    And I should not see previous versions of the recipe

  Scenario: Searching for a recipe with an update
    Given a "Buttermilk Pancake" recipe with "buttermilk" in it
    And a "Buttermilk Pancake" recipe on another day with "lowfat milk" in it
    When the "buttermilk" recipe is marked as update of the "lowfat milk" recipe
    And I search for "pancake"
    Then I should see the "buttermilk" recipe in the results
    And I should not see the "lowfat milk" recipe in the results
