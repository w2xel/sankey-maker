# language: en
@core
Feature: Core Functionality
  As a user of Sankey Maker
  I want the core functionality to work correctly
  So that I can create and manage Sankey diagrams for personal finance

  Background:
    Given the application is initialized

  # ============================================
  # APPLICATION STATE MANAGEMENT
  # ============================================

  @state
  Scenario: Initial application state
    When the application starts
    Then the application state should be empty
    And there should be 0 Sankey diagrams
    And the current diagram should be None

  @state
  Scenario: Creating a new Sankey diagram
    Given I have 0 Sankey diagrams
    When I create a new Sankey diagram named "January 2024"
    Then I should have 1 Sankey diagram
    And the current diagram should be "January 2024"
    And the diagram should have 0 flows
    And the diagram should have 0 nodes

  @state
  Scenario: Switching between diagrams
    Given I have a Sankey diagram named "Diagram 1"
    And I have a Sankey diagram named "Diagram 2"
    And the current diagram is "Diagram 1"
    When I select diagram "Diagram 2"
    Then the current diagram should be "Diagram 2"

  @state
  Scenario: Creating multiple diagrams maintains isolation
    Given I have a Sankey diagram named "Diagram 1" with a flow from "A" to "B" with value 100
    When I create a new Sankey diagram named "Diagram 2"
    Then "Diagram 1" should still have 1 flow
    And "Diagram 2" should have 0 flows
    And "Diagram 2" should have 0 nodes

  # ============================================
  # IMPLICIT NODE CREATION
  # ============================================

  @nodes @implicit
  Scenario: Adding a flow creates nodes implicitly
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    Then the diagram should have exactly 2 nodes
    And the diagram should have nodes "Salary" and "Rent"
    And the diagram should have 1 flow

  @nodes @implicit
  Scenario: Adding multiple flows creates all necessary nodes
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    And I add a flow from "Salary" to "Food" with value 500
    And I add a flow from "Bonus" to "Savings" with value 200
    Then the diagram should have exactly 5 nodes
    And the diagram should have nodes "Salary", "Rent", "Food", "Bonus", and "Savings"
    And the diagram should have 3 flows

  @nodes @implicit
  Scenario: Adding flow to existing node does not duplicate node
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I add a flow from "Salary" to "Food" with value 500
    Then the diagram should have exactly 3 nodes
    And the diagram should have nodes "Salary", "Rent", and "Food"
    And the diagram should have 2 flows
    And node "Salary" should have 2 outgoing flows

  @nodes @implicit
  Scenario: Adding flow from existing node does not duplicate node
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I add a flow from "Bonus" to "Rent" with value 200
    Then the diagram should have exactly 3 nodes
    And the diagram should have nodes "Salary", "Rent", and "Bonus"
    And the diagram should have 2 flows
    And node "Rent" should have 2 incoming flows

  @nodes @implicit
  Scenario: Node labels are case-sensitive
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    And I add a flow from "SALARY" to "rent" with value 500
    Then the diagram should have exactly 4 nodes
    And the diagram should have nodes "Salary", "Rent", "SALARY", and "rent"

  # ============================================
  # NODE MANAGEMENT
  # ============================================

  @nodes
  Scenario: Nodes are derived from flows
    Given I have a new Sankey diagram
    When I add a flow from "Income" to "Expenses" with value 500
    Then the diagram should have exactly 2 nodes
    And the nodes should be "Income" and "Expenses"

  @nodes
  Scenario: Multiple flows to same node aggregate correctly
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Bank" with value 1000
    And I add a flow from "Bonus" to "Bank" with value 200
    Then the diagram should have exactly 3 nodes
    And the diagram should have nodes "Salary", "Bonus", and "Bank"
    And node "Bank" should have 2 incoming flows with total value 1200

  @nodes
  Scenario: Node with multiple incoming and outgoing flows
    Given I have a new Sankey diagram
    When I add a flow from "Income" to "Bank" with value 1000
    And I add a flow from "Bank" to "Rent" with value 500
    And I add a flow from "Bank" to "Food" with value 300
    And I add a flow from "Bonus" to "Bank" with value 200
    Then node "Bank" should have 2 incoming flows with total value 1200
    And node "Bank" should have 2 outgoing flows with total value 800

  @nodes
  Scenario: Removing all flows to a node leaves orphaned node
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And I add a flow from "C" to "B" with value 50
    When I remove the flow from "A" to "B"
    And I remove the flow from "C" to "B"
    Then the diagram should have exactly 3 nodes
    And node "B" should have 0 incoming flows
    And node "B" should have 0 outgoing flows

  @nodes
  Scenario: Updating flow source can create new orphaned node
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow source from "A" to "C"
    Then the diagram should have exactly 3 nodes
    And the diagram should have nodes "A", "B", and "C"
    And node "A" should have 0 outgoing flows

  @nodes
  Scenario: Updating flow target can create new orphaned node
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow target from "B" to "C"
    Then the diagram should have exactly 3 nodes
    And the diagram should have nodes "A", "B", and "C"
    And node "B" should have 0 incoming flows

  # ============================================
  # FLOW MANAGEMENT
  # ============================================

  @flows
  Scenario: Adding a flow to a diagram
    Given I have a new Sankey diagram
    When I add a flow from "Source" to "Target" with value 100
    Then the diagram should have exactly 1 flow
    And the flow should have source "Source"
    And the flow should have target "Target"
    And the flow should have value 100

  @flows
  Scenario Outline: Adding flow with various valid values
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value <value>
    Then the diagram should have exactly 1 flow
    And the flow should have value <value>

    Examples:
      | value  |
      | 0.01   |
      | 1       |
      | 100     |
      | 999999  |
      | 0.5     |

  @flows
  Scenario: Adding multiple flows
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I add a flow from "A" to "C" with value 50
    Then the diagram should have exactly 3 flows

  @flows
  Scenario: Removing a flow
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I remove the flow from "A" to "B"
    Then the diagram should have 0 flows
    But the diagram should still have exactly 2 nodes "A" and "B"

  @flows
  Scenario: Removing a flow that is the only connection to a node
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I remove the flow from "A" to "B"
    Then the diagram should have exactly 2 nodes "A" and "B"
    And both nodes should have 0 connections

  @flows
  Scenario: Updating a flow value
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow from "A" to "B" to have value 200
    Then the flow from "A" to "B" should have value 200

  @flows
  Scenario: Updating a flow source
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow source from "A" to "C"
    Then the diagram should have a flow from "C" to "B" with value 100
    And the diagram should have exactly 3 nodes "A", "B", and "C"

  @flows
  Scenario: Updating a flow target
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow target from "B" to "C"
    Then the diagram should have a flow from "A" to "C" with value 100
    And the diagram should have exactly 3 nodes "A", "B", and "C"

  @flows
  Scenario: Flow IDs are unique
    Given I have a Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "C" to "D" with value 200
    Then the two flows should have different IDs

  # ============================================
  # DIAGRAM OPERATIONS
  # ============================================

  @diagrams
  Scenario: Renaming a diagram
    Given I have a Sankey diagram named "Old Name"
    When I rename the diagram to "New Name"
    Then the diagram should be named "New Name"

  @diagrams
  Scenario: Renaming diagram with duplicate name fails
    Given I have a Sankey diagram named "Diagram 1"
    And I have a Sankey diagram named "Diagram 2"
    When I try to rename "Diagram 1" to "Diagram 2"
    Then an error should be returned
    And "Diagram 1" should still be named "Diagram 1"

  @diagrams
  Scenario: Deleting a diagram
    Given I have a Sankey diagram named "To Delete"
    When I delete the diagram "To Delete"
    Then I should have 0 Sankey diagrams

  @diagrams
  Scenario: Deleting a diagram with flows
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I delete the current diagram
    Then I should have 0 Sankey diagrams
    And all flows and nodes should be removed

  @diagrams
  Scenario: Deleting current diagram clears current selection
    Given I have a Sankey diagram named "Diagram 1"
    And "Diagram 1" is the current diagram
    When I delete "Diagram 1"
    Then the current diagram should be None

  @diagrams
  Scenario: Cannot delete non-existent diagram
    Given I have a Sankey diagram named "Existing"
    When I try to delete diagram "NonExistent"
    Then an error should be returned
    And I should still have 1 Sankey diagram

  # ============================================
  # HISTORY AND UNDO/REDO
  # ============================================

  @history
  Scenario: Initial state has empty history
    Given the application is initialized
    Then the history should have 0 entries

  @history
  Scenario: Adding a flow creates history entry
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    Then the history should have exactly 1 entry
    And the last history entry should be "add_flow"

  @history
  Scenario: Multiple actions create multiple history entries
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I remove the flow from "A" to "B"
    Then the history should have exactly 3 entries

  @history @undo
  Scenario: Undo last action
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    When I undo the last action
    Then the diagram should have 0 flows
    And the history should still have 1 entry

  @history @redo
  Scenario: Redo undone action
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I undo the last action
    When I redo the last undone action
    Then the diagram should have exactly 1 flow from "A" to "B" with value 100

  @history
  Scenario: Undo and redo multiple actions
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I undo the last action
    And I undo the last action
    When I redo the last undone action
    Then the diagram should have exactly 1 flow from "A" to "B" with value 100
    When I redo the last undone action
    Then the diagram should have exactly 2 flows

  @history
  Scenario: Cannot undo when history is empty
    Given I have a new Sankey diagram
    When I try to undo the last action
    Then an error should be returned
    And the diagram should remain unchanged

  @history
  Scenario: Cannot redo when nothing has been undone
    Given I have a new Sankey diagram
    When I try to redo the last undone action
    Then an error should be returned
    And the diagram should remain unchanged

  @history
  Scenario: History is preserved per diagram
    Given I have a Sankey diagram named "Diagram 1"
    And I have a Sankey diagram named "Diagram 2"
    And "Diagram 1" is the current diagram
    When I add a flow from "A" to "B" with value 100 to "Diagram 1"
    And I switch to "Diagram 2"
    And I add a flow from "X" to "Y" with value 200 to "Diagram 2"
    And I switch back to "Diagram 1"
    When I undo the last action
    Then "Diagram 1" should have 0 flows
    And "Diagram 2" should still have 1 flow

  # ============================================
  # VALIDATION
  # ============================================

  @validation
  Scenario: Cannot add flow with negative value
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value -100
    Then the flow should not be added
    And an error should be returned with message "Value must be positive"

  @validation
  Scenario: Cannot add flow with zero value
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value 0
    Then the flow should not be added
    And an error should be returned with message "Value must be positive"

  @validation
  Scenario: Cannot add flow with empty source
    Given I have a new Sankey diagram
    When I try to add a flow from "" to "B" with value 100
    Then the flow should not be added
    And an error should be returned with message "Source cannot be empty"

  @validation
  Scenario: Cannot add flow with empty target
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "" with value 100
    Then the flow should not be added
    And an error should be returned with message "Target cannot be empty"

  @validation
  Scenario: Cannot add flow with whitespace-only source
    Given I have a new Sankey diagram
    When I try to add a flow from "   " to "B" with value 100
    Then the flow should not be added
    And an error should be returned with message "Source cannot be empty"

  @validation
  Scenario: Cannot add flow with whitespace-only target
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "   " with value 100
    Then the flow should not be added
    And an error should be returned with message "Target cannot be empty"

  @validation
  Scenario: Cannot add duplicate flow with same source and target
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I try to add a flow from "A" to "B" with value 200
    Then the diagram should still have exactly 1 flow from "A" to "B"
    And an error should be returned with message "Flow already exists"

  @validation
  Scenario: Can add flow with same source and target if first was removed
    Given I have a Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I remove the flow from "A" to "B"
    And I add a flow from "A" to "B" with value 200
    Then the diagram should have exactly 1 flow from "A" to "B" with value 200

  @validation
  Scenario: Flow value must be a finite number
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value Infinity
    Then the flow should not be added
    And an error should be returned

  @validation
  Scenario: Flow value must not be NaN
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value NaN
    Then the flow should not be added
    And an error should be returned

  # ============================================
  # DIAGRAM VALIDITY
  # ============================================

  @validity
  Scenario: Diagram with no flows is valid
    Given I have a new Sankey diagram
    Then the diagram should be valid

  @validity
  Scenario: Diagram with flows is valid
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    Then the diagram should be valid

  @validity
  Scenario: Diagram with disconnected nodes is valid
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And I add a flow from "C" to "D" with value 50
    Then the diagram should be valid
    And there should be 2 disconnected components

  @validity
  Scenario: Circular flows are allowed
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "A" with value 50
    Then the diagram should be valid
    And there should be a circular dependency between "A" and "B"

  @validity
  Scenario: Self-referencing flows are allowed
    Given I have a new Sankey diagram
    When I add a flow from "A" to "A" with value 100
    Then the diagram should be valid
    And the diagram should have exactly 1 node "A"
    And node "A" should have 1 outgoing flow to itself

  @validity
  Scenario: Diagram with orphaned nodes is valid
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And I add a node "C" explicitly
    When I remove the flow from "A" to "B"
    Then the diagram should be valid
    And the diagram should have exactly 3 nodes

  # ============================================
  # BULK OPERATIONS
  # ============================================

  @bulk
  Scenario: Adding multiple flows in one operation
    Given I have a new Sankey diagram
    When I add flows:
      | source | target | value |
      | A      | B      | 100   |
      | B      | C      | 50    |
      | A      | C      | 50    |
    Then the diagram should have exactly 3 flows
    And the diagram should have exactly 3 nodes

  @bulk
  Scenario: Bulk add with some invalid flows
    Given I have a new Sankey diagram
    When I try to add flows:
      | source | target | value |
      | A      | B      | 100   |
      | C      | D      | -50   |
      | E      | F      | 0     |
    Then the diagram should have exactly 1 flow from "A" to "B"
    And an error should be returned for the invalid flows

  @bulk
  Scenario: Removing multiple flows in one operation
    Given I have a Sankey diagram with flows from "A" to "B", "B" to "C", and "A" to "C"
    When I remove flows from "A" to "B" and from "B" to "C"
    Then the diagram should have exactly 1 flow from "A" to "C"
