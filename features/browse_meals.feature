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

    Given a "Even Fried, They Won't Eat It" meal enjoyed in May of 2009
    And a "Salad. Mmmm." meal enjoyed in April of 2009
    When I view the list of meals prepared in May of 2009
    Then I should see the "Even Fried, They Won't Eat It" meal among the meals of this month
    And I should not see the "Salad. Mmmm." meal among the meals of this month
    And I should not see a link to June 2009
    When I follow the link to the list of meals in April 2009
    Then I should not see the "Even Fried, They Won't Eat It" meal among the meals of this month
    And I should see the "Salad. Mmmm." meal among the meals of this month
    And I should not see a link to February 2009
    And I should see a link to May 2009


  Scenario: Browsing a meal on a specific date

    Given a "Focaccia!" meal enjoyed on March 3, 2009
    When I view the meal
    Then I should see the "Focaccia!" title
    And I should be able to follow a link to the list of meals in March of 2009
