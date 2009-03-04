Feature: Browse Meals

  So that I can find meals made on special occasions
  As a web user
  I want to browse meals by date

  Scenario: Add meal in a given year

    Given a "Even Fried, They Won't Eat It" meal enjoyed in 2009
    When I view the list of meals prepared in 2009
    Then "Even Fried, They Won't Eat It" should be included in the list

    Given a "Even Fried, They Won't Eat It" meal enjoyed in 2009
    And a "Salad. Mmmm." meal enjoyed in 2008
    When I view the list of meals prepared in 2009
    Then I should be able to follow a link to the list of meals in 2008
    And "Salad. Mmmm." should be included in the list

  Scenario: Add meal in a given month

    Given a "No Lycopene Tonight" meal enjoyed in May of 2008
    When I view the list of meals prepared in May of 2008
    Then "No Lycopene Tonight" should be included in the list

    Given a "Even Fried, They Won't Eat It" meal enjoyed in May of 2009
    And a "Salad. Mmmm." meal enjoyed in April of 2009
    When I view the list of meals prepared in May of 2009
    Then I should be able to follow a link to the list of meals in April of 2009
    And "Salad. Mmmm." should be included in the list

  Scenario: Add meal on a specific date

    Given a "Focaccia!" meal enjoyed on March 3, 2009
    When I view the meal
    Then I should see the "Focaccia!" title
    And I should be able to follow a link to the list of meals in March of 2009
