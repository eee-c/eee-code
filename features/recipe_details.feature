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
      And site-wide categories of Italian, Asian, Latin, Breakfast, Chicken, Fish, Meat, Salad, and Vegetarian
      When I view the recipe
      Then the Salad and Vegetarian categories should be active
