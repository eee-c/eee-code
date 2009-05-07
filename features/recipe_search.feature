Feature: Search for recipes

  So that I can find one recipe among many
  As a web user
  I want to be able search recipes

    Scenario: Matching a word in the ingredient list in full recipe search

      Given a "pancake" recipe with "chocolate chips" in it
      And a "french toast" recipe with "eggs" in it
      And a 0.5 second wait to allow the search index to be updated
      When I search for "chocolate"
      Then I should see the "pancake" recipe in the search results
      And I should not see the "french toast" recipe in the search results

    Scenario: Matching a word in the recipe summary

      Given a "pancake" recipe with a "Yummy!" summary
      And  a "french toast" recipe with a "Delicious" summary
      And a 0.5 second wait to allow the search index to be updated
      When I search for "yummy"
      Then I should see the "pancake" recipe in the search results
      And I should not see the "french toast" recipe in the search results

    Scenario: Matching a word stem in the recipe instructions

      Given a "pancake" recipe with instructions "mixing together dry ingredients"
      And a "french toast" recipe with instructions "whisking the eggs"
      And a 0.5 second wait to allow the search index to be updated
      When I search for "whisk"
      Then I should not see the "pancake" recipe in the search results
      And I should see the "french toast" recipe in the search results

    Scenario: Searching titles

      Given a "pancake" recipe
      And a "french toast" recipe with a "not a pancake" summary
      And a 0.5 second wait to allow the search index to be updated
      When I search titles for "pancake"
      Then I should see the "pancake" recipe in the search results
      And I should not see the "french toast" recipe in the search results

    Scenario: Searching ingredients

      Given a "pancake" recipe with "chocolate chips" in it
      And a "french toast" recipe with "eggs" in it and a summary of "does not go well with chocolate"
      And a 0.5 second wait to allow the search index to be updated
      When I search ingredients for "chocolate"
      Then I should see the "pancake" recipe in the search results
      And I should not see the "french toast" recipe in the search results

    Scenario: Paginating results

      Given 50 yummy recipes
      And a 0.5 second wait to allow the search index to be updated
      When I search for "yummy"
      Then I should see 20 results
      And I should see 3 pages of results
      And I should not be able to go to a previous page
      When I click page 3
      Then I should see 10 results
      And I should not be able to go to a next page
      When I click the previous page
      Then I should see 20 results
      And I should be able to go to a previous page
      When I click the next page
      Then I should see 10 results
      When I visit page -1
      Then I should see page 1
      When I visit page "foo"
      Then I should see page 1
      When I visit page 4
      Then I should see page 1

    Scenario: Sorting (name, date, preparation time, number of ingredients)

      Given 50 "delicious" recipes with ascending names, dates, preparation times, and number of ingredients
      And a 0.5 second wait to allow the search index to be updated
      When I search for "delicious"
      Then I should see 20 results
      When I click the "Name" column header
      Then the results should be ordered by name in ascending order
      When I click the "Name" column header
      Then the results should be ordered by name in descending order
      When I click the next page
      Then I should see page 2
      And the results should be ordered by name in descending order
      When I click the "Date" column header
      Then I should see page 1
      And the results should be ordered by date in descending order
      When I click the next page
      Then I should see page 2
      When I click the "Date" column header
      Then the results should be ordered by date in ascending order
      And I should see page 1
      When I click the "Prep" column header
      Then the results should be ordered by preparation time in ascending order
      When I click the "Ingredients" column header
      Then the results should be ordered by the number of ingredients in ascending order

    Scenario: No matching results

      Given 5 "Yummy" recipes
      And a 0.5 second wait to allow the search index to be updated
      When I search for "delicious"
      Then I should see no results
      And no result headings


    Scenario: Invalid search parameters

      Given 5 "Yummy" recipes
      And a 0.5 second wait to allow the search index to be updated
      When I search for ""
      Then I should see no results
      And I should see an empty query string
      When I search for an invalid lucene search term like "title:ingredient:egg"
      Then I should see no results
      And I should see an empty query string
