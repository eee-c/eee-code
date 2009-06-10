Feature: Browse Meals

  So that I can find meals made on special occasions
  As a person interested in finding meals
  I want to browse meals by date

  Scenario: Browsing a meal in a given year

    Given a "Even Fried, They Won't Eat It" meal enjoyed in 2009
    And a "Salad. Mmmm." meal enjoyed in 2008
    When I view the list of meals prepared in 2009
    Then the "Even Fried, They Won't Eat It" meal should be included in the list
    And the "Salad. Mmmm." meal should not be included in the list
    When I follow the link to the list of meals in 2008
    Then the "Even Fried, They Won't Eat It" meal should not be included in the list
    And the "Salad. Mmmm." meal should be included in the list

  Scenario: Browsing a meal in a given month

    Given a "Even Fried, They Won't Eat It" meal enjoyed in May 2009
    And a "Salad. Mmmm." meal enjoyed in April 2009
    And a "Almost French Onion Soup" meal enjoyed in September 2003
    When I view the list of meals prepared in May of 2009
    Then I should see the "Even Fried, They Won't Eat It" meal among the meals of this month
    And I should not see the "Salad. Mmmm." meal among the meals of this month
    And I should not see a link to June 2009
    When I follow the link to the list of meals in April 2009
    Then I should not see the "Even Fried, They Won't Eat It" meal among the meals of this month
    And I should see the "Salad. Mmmm." meal among the meals of this month
    And I should see a link to May 2009
    And I should not see a link to February 2009
    When I follow the link to the list of meals in September 2003
    Then I should see the "Almost French Onion Soup" meal among the meals of this month
    And I should see a link to April 2009

  Scenario: Browsing a meal on a specific date

    Given a "Focaccia" recipe from March 3, 2009
    Given a "Focaccia! The Dinner" meal with the "Focaccia" recipe on the menu
    When I view the "Focaccia! The Dinner" meal
    Then I should see the "Focaccia! The Dinner" title
    And I should see a "Focaccia" recipe link in the menu
    When I click the "March" link
    Then I should see "Focaccia! The Dinner" in the list of meals
    When I click the "Focaccia! The Dinner" link
    And I click the "2009" link
    Then I should see "Focaccia! The Dinner" in the list of meals
    When I click the "Focaccia! The Dinner" link
    When I click the "Focaccia" link
    Then I should see the "Focaccia" recipe
    When I click the "3" link
    Then I should see the "Focaccia! The Dinner" title

  Scenario: Navigating between meals

    Given a "Pumpkin is a Very Exciting Vegetable" meal enjoyed on December 3, 2008
    And a "Star Wars: The Dinner" meal enjoyed on February 28, 2009
    And a "Focaccia! The Dinner" meal enjoyed on March 3, 2009
    When I view the "Focaccia! The Dinner" meal
    Then I should see the "Focaccia! The Dinner" title
    When I click "Star Wars: The Dinner"
    Then I should see the "Star Wars: The Dinner" title
    When I click "Pumpkin is a Very Exciting Vegetable"
    Then I should see the "Pumpkin is a Very Exciting Vegetable" title
    When I click "Star Wars: The Dinner"
    Then I should see the "Star Wars: The Dinner" title
    When I click "Focaccia! The Dinner"
    Then I should see the "Focaccia! The Dinner" title
