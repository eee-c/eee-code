Feature: Mini-calendar

  As a curious web user
  I want to see a calendar indicating the most recent meals and recipes
  So that I can have a sense of how active the site is

   Scenario: Navigating through months

    Given a "Test" meal enjoyed on 2009-08-23
      And a "Test" meal enjoyed on 2009-08-15
      And a "Test" meal enjoyed on 2009-08-01
      And a "Test" meal enjoyed on 2009-06-23
     When I visit the mini-calendar
     Then I should see the calendar for August 2009
      And there should be 3 links to meals
      And there should not be a link to the next month
     When I click on the link to the previous month
     Then I should see the calendar for July 2009
      And there should be no links to meals
      And there should be a link to the next month
     When I click on the link to the previous month
     Then I should see the calendar for June 2009
      And there should be 1 links to meals
      And there should be a link to the next month
      And there should not be a link to the previous month
