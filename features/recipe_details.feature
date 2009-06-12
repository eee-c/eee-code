Feature: Recipe Details

  So that I can accurately reproduce a recipe at home
  As a web user
  I want to be able to easily recognize important details

    Scenario: Viewing a recipe with several ingredients

      Given a recipe for Buttermilk Chocolate Chip Pancakes
      When I view the recipe
      Then I should see an ingredient of "1 cup all-purpose, unbleached flour"
      And I should see an ingredient of "¼ teaspoons salt"
      And I should see an ingredient of "chocolate chips (Nestle Tollhouse)"

    Scenario: Viewing a recipe with non-active prep time

      Given a recipe for Crockpot Lentil Andouille Soup
      When I view the recipe
      Then I should see 15 minutes of prep time
      And I should see that it requires 5 hours of non-active cook time

    Scenario: Viewing a list of tools used to prepare the recipe

      Given a recipe for Chicken Noodle Soup
      When I view the recipe
      Then I should see that it requires a Bowl, a Colander, a Cutting Board, a Pot and a Skimmer to prepare

    Scenario: Main site categories

      Given a recipe for Mango and Tomato Salad
      When I view the recipe
      Then I should see the site-wide categories of Italian, Asian, Latin, Breakfast, Chicken, Fish, Meat, Salad, and Vegetarian
      And the Salad and Vegetarian categories should be active

    Scenario: Viewing summary and recipe instructions

      Given a recipe for Curried Shrimp
      When I view the recipe
      Then I should a nice summary of the dish
      And I should see detailed, easy-to-read instructions

    Scenario: Navigating to other recipes

      Given a "Spaghetti" recipe from May 30, 2009
      And a "Pizza" recipe from June 1, 2009
      And a "Peanut Butter and Jelly" recipe from June 11, 2009
      When I view the "Peanut Butter and Jelly" recipe
      Then I should see the "Peanut Butter and Jelly" title
      When I click "Pizza"
      Then I should see the "Pizza" title
      When I click "Spaghetti"
      Then I should see the "Spaghetti" title
      When I click "Pizza"
      Then I should see the "Pizza" title
      When I click "Peanut Butter and Jelly"
      Then I should see the "Peanut Butter and Jelly" title
