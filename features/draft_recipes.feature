Feature: Draft vs. Published Meals and Recipes

  As a cookbook dedicated to quality
  So that I can present only the best meals and recipes
  I want to hide drafts

    Scenario: Navigating between recipes
      Given "Recipe #1", published on 2009-08-01
        And "Recipe #2", drafted on 2009-08-05
        And "Recipe #3", published on 2009-08-10
        And "Recipe #4", drafted on 2009-08-20
       When I show "Recipe #1"
       Then there should be no link to "Recipe #2"
       When I am asked for the next recipe
       Then "Recipe #3" should be shown
        And there should be no next link
        And there should be a link to "Recipe #1"

    Scenario: Searching for recipes
      Given "Recipe #1", published on 2009-08-01
        And "Recipe #2", drafted on 2009-08-05
        And "Recipe #3", published on 2009-08-10
        And "Recipe #4", drafted on 2009-08-20
       When I show all recipes via search
       Then "Recipe #1 and Recipe #3" should be included in the search results
        And "Recipe #2 and Recipe #4" should not be included in the search results

    Scenario: Navigating between meals
      Given "Meal #1", published on 2009-08-01
        And "Meal #2", drafted on 2009-08-05
        And "Meal #3", published on 2009-08-10
        And "Meal #4", drafted on 2009-08-20
       When I show "Meal #1"
       Then there should be no link to "Meal #2"
       When I am asked for the next meal
       Then "Meal #3" should be shown
        And there should be no next link
        And there should be a link to "Meal #1"
       When I am asked for the list of meals in 2009-08
       Then "Meal #1 and Meal #3" should be included
        And "Meal #2 and Meal #4" should not be included
       When I am asked for the list of meals in 2009
       Then "Meal #1 and Meal #3" should be included
        And "Meal #2 and Meal #4" should not be included
       When I am asked for the homepage
       Then "Meal #1 and Meal #3" should be included
        And "Meal #2 and Meal #4" should not be included

