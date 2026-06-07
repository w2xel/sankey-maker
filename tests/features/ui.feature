# language: en
@ui
Feature: User Interface
  As a user of Sankey Maker
  I want the UI to be responsive and intuitive
  So that I can easily create and manage Sankey diagrams

  Background:
    Given the application is running
    And I am on the main screen

  # ============================================
  # LAYOUT AND NAVIGATION
  # ============================================

  @layout
  Scenario: Three column layout is displayed
    When I open the application
    Then I should see three columns
    And the left column should show diagram list
    And the middle column should show flow list
    And the right column should show Sankey diagram

  @layout
  Scenario: Left column can be hidden
    When I click the toggle button for the left column
    Then the left column should be hidden
    And the middle and right columns should expand to fill the space

  @layout
  Scenario: Left column can be shown again
    Given the left column is hidden
    When I click the toggle button for the left column
    Then the left column should be visible
    And the layout should return to three columns

  @layout
  Scenario: Responsive layout on small screens
    Given the screen width is less than 768px
    When I open the application
    Then the layout should adapt to mobile view
    And the left column should be hidden by default

  @navigation
  Scenario: Navigation between diagrams
    Given I have 2 Sankey diagrams: "Diagram 1" and "Diagram 2"
    When I click on "Diagram 2" in the left column
    Then the middle column should show flows from "Diagram 2"
    And the right column should show the Sankey diagram for "Diagram 2"

  # ============================================
  # DIAGRAM LIST (LEFT COLUMN)
  # ============================================

  @diagram_list
  Scenario: Diagram list shows all diagrams
    Given I have 3 Sankey diagrams
    When I look at the left column
    Then I should see all 3 diagrams listed

  @diagram_list
  Scenario: Creating new diagram from UI
    When I click the "New Diagram" button
    Then a new diagram should be created
    And the new diagram should be selected
    And I should be able to edit the diagram name

  @diagram_list
  Scenario: Renaming diagram from UI
    Given I have a Sankey diagram named "Old Name"
    When I click the edit button for "Old Name"
    And I enter "New Name"
    And I confirm the change
    Then the diagram should be renamed to "New Name"

  @diagram_list
  Scenario: Deleting diagram from UI
    Given I have a Sankey diagram named "To Delete"
    When I click the delete button for "To Delete"
    And I confirm the deletion
    Then the diagram should be removed
    And it should no longer appear in the list

  @diagram_list
  Scenario: Selecting diagram from list
    Given I have 2 Sankey diagrams
    When I click on the second diagram in the list
    Then that diagram should become the current diagram
    And its flows should be displayed in the middle column

  @diagram_list
  Scenario: Diagram list shows current diagram
    Given I have 2 Sankey diagrams
    And "Diagram 1" is currently selected
    When I look at the diagram list
    Then "Diagram 1" should be highlighted as selected

  @diagram_list
  Scenario: Empty diagram list
    Given I have no Sankey diagrams
    When I look at the left column
    Then I should see a message indicating no diagrams exist
    And I should see a button to create a new diagram

  # ============================================
  # FLOW LIST (MIDDLE COLUMN)
  # ============================================

  @flow_list
  Scenario: Flow list shows all flows in current diagram
    Given I have a Sankey diagram with 3 flows
    When I look at the middle column
    Then I should see all 3 flows listed

  @flow_list
  Scenario: Adding flow from UI
    Given I have a Sankey diagram
    When I click the "Add Flow" button
    And I enter source "Salary"
    And I enter target "Rent"
    And I enter value "1000"
    And I confirm the addition
    Then a new flow should be added from "Salary" to "Rent" with value 1000
    And the flow should appear in the flow list

  @flow_list
  Scenario: Editing flow from UI
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click the edit button for the flow
    And I change the value to "200"
    And I confirm the change
    Then the flow should be updated to have value 200

  @flow_list
  Scenario: Deleting flow from UI
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click the delete button for the flow
    And I confirm the deletion
    Then the flow should be removed
    And it should no longer appear in the flow list

  @flow_list
  Scenario: Flow list updates when diagram changes
    Given I have a Sankey diagram with 1 flow
    And I am viewing the flow list
    When I add a new flow
    Then the flow list should update to show 2 flows

  @flow_list
  Scenario: Empty flow list
    Given I have a Sankey diagram with no flows
    When I look at the middle column
    Then I should see a message indicating no flows exist
    And I should see a button to add a new flow

  @flow_list
  Scenario: Flow list shows flow details
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I look at the flow list
    Then I should see the source "Salary"
    And I should see the target "Rent"
    And I should see the value "1000"

  # ============================================
  # SANKEY VIEWER (RIGHT COLUMN)
  # ============================================

  @sankey_viewer
  Scenario: Sankey diagram is rendered
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I look at the right column
    Then I should see a Sankey diagram
    And the diagram should show nodes "A" and "B"
    And the diagram should show a flow from "A" to "B"

  @sankey_viewer
  Scenario: Sankey diagram updates when flows change
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And the Sankey diagram is rendered
    When I add a flow from "B" to "C" with value 50
    Then the Sankey diagram should update
    And it should show the new flow from "B" to "C"

  @sankey_viewer
  Scenario: Sankey diagram shows node labels
    Given I have a Sankey diagram with a flow from "Income" to "Expenses" with value 1000
    When I look at the Sankey diagram
    Then I should see the label "Income"
    And I should see the label "Expenses"

  @sankey_viewer
  Scenario: Sankey diagram shows flow values
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I look at the Sankey diagram
    Then I should see the value "100" associated with the flow

  @sankey_viewer
  Scenario: Sankey diagram is interactive
    Given I have a Sankey diagram with multiple flows
    When I hover over a flow
    Then the flow should be highlighted
    And a tooltip should show flow details

  @sankey_viewer
  Scenario: Sankey diagram handles node positioning
    Given I have a Sankey diagram with flows from "A" to "B" and "A" to "C"
    When I look at the Sankey diagram
    Then nodes should be positioned to avoid overlaps
    And flows should be clearly visible

  @sankey_viewer
  Scenario: Empty Sankey diagram
    Given I have a Sankey diagram with no flows
    When I look at the right column
    Then I should see a message indicating no diagram to display
    Or I should see an empty diagram area

  # ============================================
  # TOOLBAR AND ACTIONS
  # ============================================

  @toolbar
  Scenario: Toolbar is visible
    When I open the application
    Then I should see a toolbar at the top
    And the toolbar should contain action buttons

  @toolbar
  Scenario: New diagram button
    When I click the "New" button in the toolbar
    Then a new diagram should be created

  @toolbar
  Scenario: Save button
    Given I have a Sankey diagram with changes
    When I click the "Save" button in the toolbar
    Then the diagram should be saved

  @toolbar
  Scenario: Export button
    Given I have a Sankey diagram
    When I click the "Export" button in the toolbar
    Then I should see export options

  @toolbar
  Scenario: Undo button
    Given I have made changes to a diagram
    When I click the "Undo" button in the toolbar
    Then the last change should be undone

  @toolbar
  Scenario: Redo button
    Given I have undone a change
    When I click the "Redo" button in the toolbar
    Then the undone change should be redone

  @toolbar
  Scenario: Toolbar buttons are disabled when appropriate
    Given I have no Sankey diagrams
    When I look at the toolbar
    Then the Save button should be disabled
    And the Export button should be disabled
    And the Undo button should be disabled
    And the Redo button should be disabled

  # ============================================
  # EXPORT DIALOG
  # ============================================

  @export_dialog
  Scenario: Export dialog opens
    Given I have a Sankey diagram
    When I click the "Export" button
    Then the export dialog should open

  @export_dialog
  Scenario: Export as PNG
    Given I have a Sankey diagram
    And the export dialog is open
    When I select "PNG" format
    And I click "Export"
    Then a PNG file should be downloaded

  @export_dialog
  Scenario: Export as SVG
    Given I have a Sankey diagram
    And the export dialog is open
    When I select "SVG" format
    And I click "Export"
    Then an SVG file should be downloaded

  @export_dialog
  Scenario: Export as TOML
    Given I have a Sankey diagram
    And the export dialog is open
    When I select "TOML" format
    And I click "Export"
    Then a TOML file should be downloaded

  @export_dialog
  Scenario: Export as JSON
    Given I have a Sankey diagram
    And the export dialog is open
    When I select "JSON" format
    And I click "Export"
    Then a JSON file should be downloaded

  @export_dialog
  Scenario: Export dialog shows filename
    Given I have a Sankey diagram named "My Diagram"
    And the export dialog is open
    When I select a format
    Then the suggested filename should include "My Diagram"

  # ============================================
  # IMPORT DIALOG
  # ============================================

  @import_dialog
  Scenario: Import dialog opens
    When I click the "Import" button
    Then the import dialog should open

  @import_dialog
  Scenario: Import TOML file
    Given I have a TOML file with a Sankey diagram
    And the import dialog is open
    When I select the TOML file
    And I click "Import"
    Then the diagram should be imported
    And it should appear in my diagram list

  @import_dialog
  Scenario: Import JSON file
    Given I have a JSON file with a Sankey diagram
    And the import dialog is open
    When I select the JSON file
    And I click "Import"
    Then the diagram should be imported

  @import_dialog
  Scenario: Import invalid file
    Given I have an invalid file
    And the import dialog is open
    When I select the invalid file
    And I click "Import"
    Then an error message should be displayed
    And no diagram should be imported

  # ============================================
  # KEYBOARD SHORTCUTS
  # ============================================

  @keyboard
  Scenario: Ctrl+N creates new diagram
    When I press Ctrl+N
    Then a new diagram should be created

  @keyboard
  Scenario: Ctrl+S saves current diagram
    Given I have a Sankey diagram with changes
    When I press Ctrl+S
    Then the diagram should be saved

  @keyboard
  Scenario: Ctrl+E opens export dialog
    Given I have a Sankey diagram
    When I press Ctrl+E
    Then the export dialog should open

  @keyboard
  Scenario: Ctrl+Z undoes last action
    Given I have made changes to a diagram
    When I press Ctrl+Z
    Then the last change should be undone

  @keyboard
  Scenario: Ctrl+Y redoes last undone action
    Given I have undone a change
    When I press Ctrl+Y
    Then the undone change should be redone

  @keyboard
  Scenario: Delete removes selected flow
    Given I have a Sankey diagram with a flow from "A" to "B"
    And the flow is selected
    When I press Delete
    Then the flow should be removed

  @keyboard
  Scenario: Escape cancels current operation
    Given I am editing a flow
    When I press Escape
    Then the editing should be cancelled
    And the flow should remain unchanged

  # ============================================
  # FORM VALIDATION
  # ============================================

  @validation
  Scenario: Flow form validates source
    Given I am adding a new flow
    When I leave the source field empty
    And I try to submit the form
    Then an error should be displayed
    And the flow should not be added

  @validation
  Scenario: Flow form validates target
    Given I am adding a new flow
    When I leave the target field empty
    And I try to submit the form
    Then an error should be displayed
    And the flow should not be added

  @validation
  Scenario: Flow form validates value
    Given I am adding a new flow
    When I enter "abc" in the value field
    And I try to submit the form
    Then an error should be displayed
    And the flow should not be added

  @validation
  Scenario: Flow form validates positive value
    Given I am adding a new flow
    When I enter "-100" in the value field
    And I try to submit the form
    Then an error should be displayed
    And the flow should not be added

  @validation
  Scenario: Flow form shows validation errors
    Given I am adding a new flow
    When I leave all fields empty
    And I try to submit the form
    Then I should see error messages for all required fields

  # ============================================
  # NOTIFICATIONS AND FEEDBACK
  # ============================================

  @feedback
  Scenario: Success notification on save
    Given I have a Sankey diagram with changes
    When I click the "Save" button
    Then a success notification should appear
    And the notification should disappear after a few seconds

  @feedback
  Scenario: Error notification on failed save
    Given the storage is not accessible
    When I try to save a diagram
    Then an error notification should appear
    And the notification should indicate the problem

  @feedback
  Scenario: Loading indicator during operations
    Given I am performing a long operation
    When the operation starts
    Then a loading indicator should appear
    And when the operation completes
    Then the loading indicator should disappear

  @feedback
  Scenario: Confirmation dialog for destructive actions
    Given I have a Sankey diagram
    When I try to delete the diagram
    Then a confirmation dialog should appear
    And I should have to confirm before the deletion occurs

  # ============================================
  # RESPONSIVE DESIGN
  # ============================================

  @responsive
  Scenario: Layout adapts to screen size
    Given the screen width is 1024px
    When I resize the screen to 768px
    Then the layout should adapt
    And all content should remain accessible

  @responsive
  Scenario: Touch support on mobile devices
    Given I am using a touch device
    When I interact with the UI
    Then touch gestures should work
    And all functionality should be accessible

  @responsive
  Scenario: Scroll behavior on small screens
    Given I have a Sankey diagram with many flows
    And I am on a small screen
    When the content overflows the screen
    Then scroll bars should appear
    And I should be able to scroll to see all content

  # ============================================
  # ACCESSIBILITY
  # ============================================

  @accessibility
  Scenario: Keyboard navigation
    When I use Tab to navigate
    Then I should be able to access all interactive elements
    And the focus should be visible

  @accessibility
  Scenario: Screen reader support
    When I use a screen reader
    Then all interactive elements should have appropriate labels
    And the screen reader should announce changes

  @accessibility
  Scenario: High contrast mode
    Given I have high contrast mode enabled
    When I view the application
    Then the UI should be readable
    And all interactive elements should be visible