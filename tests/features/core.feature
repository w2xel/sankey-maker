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

  # ============================================
  # IMPLICIT NODE CREATION
  # ============================================

  @nodes @implicit
  Scenario: Adding a flow creates nodes implicitly
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    Then the diagram should have nodes "Salary" and "Rent"
    And the diagram should have 1 flow

  @nodes @implicit
  Scenario: Adding multiple flows creates all necessary nodes
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    And I add a flow from "Salary" to "Food" with value 500
    And I add a flow from "Bonus" to "Savings" with value 200
    Then the diagram should have nodes "Salary", "Rent", "Food", "Bonus", and "Savings"
    And the diagram should have 3 flows

  @nodes @implicit
  Scenario: Adding flow to existing node
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I add a flow from "Salary" to "Food" with value 500
    Then the diagram should have nodes "Salary", "Rent", and "Food"
    And the diagram should have 2 flows
    And node "Salary" should have 2 outgoing flows

  @nodes @implicit
  Scenario: Adding flow from existing node
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I add a flow from "Bonus" to "Rent" with value 200
    Then the diagram should have nodes "Salary", "Rent", and "Bonus"
    And the diagram should have 2 flows
    And node "Rent" should have 2 incoming flows

  # ============================================
  # FLOW MANAGEMENT
  # ============================================

  @flows
  Scenario: Adding a flow to a diagram
    Given I have a new Sankey diagram
    When I add a flow from "Source" to "Target" with value 100
    Then the diagram should have 1 flow
    And the flow should have source "Source"
    And the flow should have target "Target"
    And the flow should have value 100

  @flows
  Scenario: Adding multiple flows
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I add a flow from "A" to "C" with value 50
    Then the diagram should have 3 flows

  @flows
  Scenario: Removing a flow
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I remove the flow from "A" to "B"
    Then the diagram should have 0 flows
    But the diagram should still have nodes "A" and "B"

  @flows
  Scenario: Removing a flow that is the only connection to a node
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I remove the flow from "A" to "B"
    Then the diagram should have nodes "A" and "B"
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
    And the diagram should have nodes "C", "B", and "A"

  @flows
  Scenario: Updating a flow target
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I update the flow target from "B" to "C"
    Then the diagram should have a flow from "A" to "C" with value 100
    And the diagram should have nodes "A", "B", and "C"

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
  Scenario: Multiple flows to same node
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Bank" with value 1000
    And I add a flow from "Bonus" to "Bank" with value 200
    Then the diagram should have nodes "Salary", "Bonus", and "Bank"
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

  # ============================================
  # DIAGRAM OPERATIONS
  # ============================================

  @diagrams
  Scenario: Renaming a diagram
    Given I have a Sankey diagram named "Old Name"
    When I rename the diagram to "New Name"
    Then the diagram should be named "New Name"

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

  # ============================================
  # HISTORY AND UNDO/REDO
  # ============================================

  @history
  Scenario: Adding a flow creates history entry
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    Then the history should have 1 entry
    And the last history entry should be "add_flow"

  @history
  Scenario: Multiple actions create multiple history entries
    Given I have a new Sankey diagram
    When I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I remove the flow from "A" to "B"
    Then the history should have 3 entries

  @history @undo
  Scenario: Undo last action
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    When I undo the last action
    Then the diagram should have 0 flows
    And the history should still have 1 entry (for undo tracking)

  @history @redo
  Scenario: Redo undone action
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I undo the last action
    When I redo the last undone action
    Then the diagram should have 1 flow from "A" to "B" with value 100

  @history
  Scenario: Undo and redo multiple actions
    Given I have a new Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I add a flow from "B" to "C" with value 50
    And I undo the last action
    And I undo the last action
    When I redo the last undone action
    Then the diagram should have 1 flow from "A" to "B" with value 100
    When I redo the last undone action
    Then the diagram should have 2 flows

  # ============================================
  # VALIDATION
  # ============================================

  @validation
  Scenario: Cannot add flow with negative value
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value -100
    Then the flow should not be added
    And an error should be returned

  @validation
  Scenario: Cannot add flow with zero value
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "B" with value 0
    Then the flow should not be added
    And an error should be returned

  @validation
  Scenario: Cannot add flow with empty source
    Given I have a new Sankey diagram
    When I try to add a flow from "" to "B" with value 100
    Then the flow should not be added
    And an error should be returned

  @validation
  Scenario: Cannot add flow with empty target
    Given I have a new Sankey diagram
    When I try to add a flow from "A" to "" with value 100
    Then the flow should not be added
    And an error should be returned

  @validation
  Scenario: Cannot add duplicate flow
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I try to add a flow from "A" to "B" with value 200
    Then the diagram should still have 1 flow from "A" to "B"
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