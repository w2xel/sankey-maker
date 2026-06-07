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
  Scenario: Main interface elements are visible
    When I open the application
    Then I should see the diagram list
    And I should see the flow list
    And I should see the Sankey diagram viewer
    And I should see the toolbar

  @layout
  Scenario: Diagram list can be hidden and shown
    When I click the toggle button for the diagram list
    Then the diagram list should be hidden
    And the remaining space should be used by other elements
    When I click the toggle button for the diagram list again
    Then the diagram list should be visible

  @layout
  Scenario: Responsive layout on small screens
    Given the screen width is less than 768px
    When I open the application
    Then the diagram list should be hidden by default
    And I should see a button to show the diagram list
    And the flow list and diagram viewer should be stacked vertically

  @layout
  Scenario: Layout adapts when resizing window
    Given the screen width is 1024px
    And the diagram list is visible
    When I resize the screen to 768px width
    Then the diagram list should be hidden automatically
    And all content should remain accessible

  @navigation
  Scenario: Navigation between diagrams
    Given I have 2 Sankey diagrams: "Diagram 1" and "Diagram 2"
    And "Diagram 1" is currently selected
    When I click on "Diagram 2" in the diagram list
    Then the flow list should show flows from "Diagram 2"
    And the Sankey diagram viewer should show the diagram for "Diagram 2"
    And "Diagram 2" should be highlighted as selected in the list

  @navigation
  Scenario: Current diagram is highlighted in list
    Given I have 2 Sankey diagrams
    And "Diagram 1" is currently selected
    When I look at the diagram list
    Then "Diagram 1" should be visually highlighted as selected
    And "Diagram 2" should not be highlighted

  # ============================================
  # DIAGRAM LIST (LEFT PANEL)
  # ============================================

  @diagram_list
  Scenario: Diagram list shows all diagrams
    Given I have 3 Sankey diagrams: "Diagram 1", "Diagram 2", "Diagram 3"
    When I look at the diagram list
    Then I should see all 3 diagrams listed
    And each diagram should show its name

  @diagram_list
  Scenario: Creating new diagram from UI
    When I click the "New Diagram" button
    Then a new diagram should be created
    And the new diagram should be selected
    And I should be able to edit the diagram name

  @diagram_list
  Scenario: New diagram has default name
    When I click the "New Diagram" button
    Then the new diagram should have a default name like "Untitled" or "New Diagram"

  @diagram_list
  Scenario: Renaming diagram from UI
    Given I have a Sankey diagram named "Old Name"
    When I click the edit button for "Old Name"
    And I enter "New Name"
    And I confirm the change
    Then the diagram should be renamed to "New Name"
    And the change should be reflected in the list

  @diagram_list
  Scenario: Renaming diagram with duplicate name shows error
    Given I have a Sankey diagram named "Diagram 1"
    And I have a Sankey diagram named "Diagram 2"
    When I try to rename "Diagram 1" to "Diagram 2"
    Then an error message should be displayed
    And "Diagram 1" should keep its original name

  @diagram_list
  Scenario: Deleting diagram from UI with confirmation
    Given I have a Sankey diagram named "To Delete"
    When I click the delete button for "To Delete"
    Then a confirmation dialog should appear
    When I confirm the deletion
    Then the diagram should be removed
    And it should no longer appear in the list

  @diagram_list
  Scenario: Deleting diagram can be cancelled
    Given I have a Sankey diagram named "To Delete"
    When I click the delete button for "To Delete"
    And I cancel the deletion
    Then the diagram should not be removed
    And it should still appear in the list

  @diagram_list
  Scenario: Selecting diagram from list
    Given I have 2 Sankey diagrams
    When I click on the second diagram in the list
    Then that diagram should become the current diagram
    And its flows should be displayed in the flow list
    And its visualization should be displayed in the viewer

  @diagram_list
  Scenario: Empty diagram list shows helpful message
    Given I have no Sankey diagrams
    When I look at the diagram list
    Then I should see a message indicating no diagrams exist
    And I should see a prominent button to create a new diagram

  @diagram_list
  Scenario: Diagram list can be sorted
    Given I have 3 Sankey diagrams: "Zebra", "Apple", "Mango"
    When I sort the diagram list alphabetically
    Then the diagrams should appear in order: "Apple", "Mango", "Zebra"

  @diagram_list
  Scenario: Diagram list shows diagram metadata
    Given I have a Sankey diagram named "January" with 5 flows
    And I have a Sankey diagram named "February" with 10 flows
    When I look at the diagram list
    Then I should see the number of flows for each diagram
    And I should see the last modified date for each diagram

  # ============================================
  # FLOW LIST (MIDDLE PANEL)
  # ============================================

  @flow_list
  Scenario: Flow list shows all flows in current diagram
    Given I have a Sankey diagram with 3 flows
    When I look at the flow list
    Then I should see all 3 flows listed

  @flow_list
  Scenario: Flow list shows flow details
    Given I have a Sankey diagram with a flow from "Salary" to "Rent" with value 1000
    When I look at the flow list
    Then I should see the source "Salary"
    And I should see the target "Rent"
    And I should see the value "1000"

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
  Scenario: Adding flow with invalid data shows validation errors
    Given I have a Sankey diagram
    When I click the "Add Flow" button
    And I leave the source field empty
    And I leave the target field empty
    And I enter "abc" in the value field
    And I try to submit the form
    Then I should see error messages for all required fields
    And the flow should not be added

  @flow_list
  Scenario: Editing flow from UI
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click the edit button for the flow
    And I change the value to "200"
    And I confirm the change
    Then the flow should be updated to have value 200
    And the change should be reflected in the flow list

  @flow_list
  Scenario: Deleting flow from UI with confirmation
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click the delete button for the flow
    And I confirm the deletion
    Then the flow should be removed
    And it should no longer appear in the flow list

  @flow_list
  Scenario: Deleting flow can be cancelled
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click the delete button for the flow
    And I cancel the deletion
    Then the flow should not be removed
    And it should still appear in the flow list

  @flow_list
  Scenario: Flow list updates when diagram changes
    Given I have a Sankey diagram with 1 flow
    And I am viewing the flow list
    When I add a new flow
    Then the flow list should update to show 2 flows

  @flow_list
  Scenario: Empty flow list shows helpful message
    Given I have a Sankey diagram with no flows
    When I look at the flow list
    Then I should see a message indicating no flows exist
    And I should see a button to add a new flow

  @flow_list
  Scenario: Flow list can be sorted
    Given I have a Sankey diagram with flows from "A" to "B", "C" to "D", "E" to "F"
    When I sort the flow list by source alphabetically
    Then the flows should appear in order: "A" to "B", "C" to "D", "E" to "F"

  @flow_list
  Scenario: Flow list can be filtered
    Given I have a Sankey diagram with flows from "Salary" to "Rent", "Salary" to "Food", "Bonus" to "Savings"
    When I filter the flow list by source "Salary"
    Then I should see only flows from "Salary"
    And I should see 2 flows

  @flow_list
  Scenario: Selecting flow highlights it in viewer
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And the Sankey diagram is rendered
    When I click on the flow in the flow list
    Then the flow should be highlighted in the Sankey diagram viewer

  # ============================================
  # SANKEY VIEWER (RIGHT PANEL)
  # ============================================

  @sankey_viewer
  Scenario: Sankey diagram is rendered
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I look at the Sankey diagram viewer
    Then I should see a Sankey diagram
    And the diagram should show nodes "A" and "B"
    And the diagram should show a flow from "A" to "B"

  @sankey_viewer
  Scenario: Sankey diagram updates when flows change
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And the Sankey diagram is rendered
    When I add a flow from "B" to "C" with value 50
    Then the Sankey diagram should update within 500ms
    And it should show the new flow from "B" to "C"

  @sankey_viewer
  Scenario: Sankey diagram shows node labels
    Given I have a Sankey diagram with a flow from "Income" to "Expenses" with value 1000
    When I look at the Sankey diagram
    Then I should see the label "Income"
    And I should see the label "Expenses"
    And the labels should be fully visible and not truncated

  @sankey_viewer
  Scenario: Sankey diagram shows flow values
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I look at the Sankey diagram
    Then I should see the value "100" associated with the flow
    And the value should be positioned near the flow

  @sankey_viewer
  Scenario: Sankey diagram is interactive - hover
    Given I have a Sankey diagram with multiple flows
    When I hover over a flow with the mouse
    Then the flow should be visually highlighted
    And a tooltip should appear showing the flow details

  @sankey_viewer
  Scenario: Sankey diagram handles node positioning automatically
    Given I have a Sankey diagram with flows from "A" to "B" and "A" to "C"
    When I look at the Sankey diagram
    Then nodes should be positioned to minimize overlaps
    And all flows should be clearly visible
    And no nodes should overlap

  @sankey_viewer
  Scenario: Sankey diagram can be zoomed
    Given I have a Sankey diagram with multiple flows
    When I use the mouse wheel to zoom in
    Then the diagram should appear larger
    And I should see more detail
    When I use the mouse wheel to zoom out
    Then the diagram should appear smaller
    And I should see more of the diagram

  @sankey_viewer
  Scenario: Sankey diagram can be panned
    Given I have a Sankey diagram with many nodes
    And the diagram is zoomed in
    When I click and drag the diagram
    Then the view should move in the direction of the drag
    And nodes should move relative to the viewport

  @sankey_viewer
  Scenario: Sankey diagram nodes can be dragged
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I click and drag node "A" to a new position
    Then node "A" should move to the new position
    And the flow from "A" to "B" should update to connect to the new position

  @sankey_viewer
  Scenario: Empty Sankey diagram shows helpful message
    Given I have a Sankey diagram with no flows
    When I look at the Sankey diagram viewer
    Then I should see a message indicating no diagram to display
    Or I should see an empty diagram area with instructions

  @sankey_viewer
  Scenario: Sankey diagram respects minimum node width
    Given I have a Sankey diagram with a flow from "Very Long Node Name That Is Quite Lengthy" to "B" with value 100
    When I look at the Sankey diagram
    Then the node label should be fully visible
    And the node should have sufficient width to display the label

  @sankey_viewer
  Scenario: Sankey diagram shows flow direction
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I look at the Sankey diagram
    Then the flow should have a clear direction from "A" to "B"
    And the direction should be visually distinguishable

  # ============================================
  # TOOLBAR AND ACTIONS
  # ============================================

  @toolbar
  Scenario: Toolbar is visible
    When I open the application
    Then I should see a toolbar at the top of the screen
    And the toolbar should contain action buttons

  @toolbar
  Scenario: New diagram button creates new diagram
    When I click the "New" button in the toolbar
    Then a new diagram should be created
    And the new diagram should be selected

  @toolbar
  Scenario: Save button saves current diagram
    Given I have a Sankey diagram with changes
    When I click the "Save" button in the toolbar
    Then the diagram should be saved
    And a success notification should appear briefly

  @toolbar
  Scenario: Export button opens export dialog
    Given I have a Sankey diagram
    When I click the "Export" button in the toolbar
    Then the export dialog should open

  @toolbar
  Scenario: Import button opens import dialog
    When I click the "Import" button in the toolbar
    Then the import dialog should open

  @toolbar
  Scenario: Undo button undoes last action
    Given I have made changes to a diagram
    When I click the "Undo" button in the toolbar
    Then the last change should be undone

  @toolbar
  Scenario: Redo button redoes last undone action
    Given I have undone a change
    When I click the "Redo" button in the toolbar
    Then the undone change should be redone

  @toolbar
  Scenario: Toolbar buttons are disabled when inappropriate
    Given I have no Sankey diagrams
    When I look at the toolbar
    Then the Save button should be disabled
    And the Export button should be disabled
    And the Undo button should be disabled
    And the Redo button should be disabled

  @toolbar
  Scenario: Toolbar buttons enable when appropriate
    Given I have a Sankey diagram with unsaved changes
    When I look at the toolbar
    Then the Save button should be enabled
    And the Export button should be enabled
    And the Undo button should be enabled

  @toolbar
  Scenario: Toolbar shows current diagram name
    Given I have a Sankey diagram named "My Diagram"
    And "My Diagram" is the current diagram
    When I look at the toolbar
    Then I should see "My Diagram" displayed

  # ============================================
  # EXPORT DIALOG
  # ============================================

  @export_dialog
  Scenario: Export dialog opens
    Given I have a Sankey diagram
    When I click the "Export" button
    Then the export dialog should open
    And the dialog should show export format options

  @export_dialog
  Scenario Outline: Exporting diagram to various formats
    Given I have a Sankey diagram
    And the export dialog is open
    When I select "<format>" format
    And I click "Export"
    Then a file download should start
    And the downloaded file should have the ".<ext>" extension

    Examples:
      | format | ext   |
      | PNG    | png   |
      | SVG    | svg   |
      | TOML   | toml  |
      | JSON   | json  |

  @export_dialog
  Scenario: Export dialog shows suggested filename
    Given I have a Sankey diagram named "My Diagram"
    And the export dialog is open
    When I select a format
    Then the suggested filename should be "My Diagram" with the appropriate extension

  @export_dialog
  Scenario: Export dialog allows custom filename
    Given I have a Sankey diagram
    And the export dialog is open
    When I enter "Custom Name" as the filename
    And I select "PNG" format
    And I click "Export"
    Then the downloaded file should be named "Custom Name.png"

  @export_dialog
  Scenario: Export dialog can be cancelled
    Given I have a Sankey diagram
    And the export dialog is open
    When I click "Cancel"
    Then the export dialog should close
    And no file should be downloaded

  # ============================================
  # IMPORT DIALOG
  # ============================================

  @import_dialog
  Scenario: Import dialog opens
    When I click the "Import" button
    Then the import dialog should open
    And the dialog should show file selection options

  @import_dialog
  Scenario Outline: Importing diagram from various formats
    Given I have a "<format>" file with a Sankey diagram
    And the import dialog is open
    When I select the file
    And I click "Import"
    Then the diagram should be imported
    And it should appear in my diagram list

    Examples:
      | format |
      | TOML   |
      | JSON   |

  @import_dialog
  Scenario: Importing invalid file shows error
    Given I have an invalid file
    And the import dialog is open
    When I select the invalid file
    And I click "Import"
    Then an error message should be displayed
    And the error message should explain why the import failed
    And no diagram should be imported

  @import_dialog
  Scenario: Importing file with duplicate diagram name
    Given I have a Sankey diagram named "Existing"
    And I have a TOML file with a diagram named "Existing"
    And the import dialog is open
    When I select the TOML file
    And I click "Import"
    Then the imported diagram should have a unique name like "Existing (1)"

  @import_dialog
  Scenario: Import dialog can be cancelled
    Given the import dialog is open
    When I click "Cancel"
    Then the import dialog should close
    And no diagram should be imported

  # ============================================
  # KEYBOARD SHORTCUTS
  # ============================================

  @keyboard
  Scenario: New diagram shortcut
    When I press the new diagram keyboard shortcut
    Then a new diagram should be created

  @keyboard
  Scenario: Save diagram shortcut
    Given I have a Sankey diagram with changes
    When I press the save diagram keyboard shortcut
    Then the diagram should be saved

  @keyboard
  Scenario: Export diagram shortcut
    Given I have a Sankey diagram
    When I press the export diagram keyboard shortcut
    Then the export dialog should open

  @keyboard
  Scenario: Undo shortcut
    Given I have made changes to a diagram
    When I press the undo keyboard shortcut
    Then the last change should be undone

  @keyboard
  Scenario: Redo shortcut
    Given I have undone a change
    When I press the redo keyboard shortcut
    Then the undone change should be redone

  @keyboard
  Scenario: Delete removes selected flow
    Given I have a Sankey diagram with a flow from "A" to "B"
    And the flow is selected
    When I press the delete keyboard shortcut
    Then the flow should be removed

  @keyboard
  Scenario: Escape cancels current operation
    Given I am editing a flow
    When I press the escape keyboard shortcut
    Then the editing should be cancelled
    And the flow should remain unchanged

  @keyboard
  Scenario: Keyboard shortcuts work with focus on different elements
    Given I have a Sankey diagram
    When I click on the flow list
    And I press the new diagram keyboard shortcut
    Then a new diagram should be created

  # ============================================
  # FORM VALIDATION
  # ============================================

  @validation
  Scenario: Flow form validates source is not empty
    Given I am adding a new flow
    When I leave the source field empty
    And I try to submit the form
    Then an error message should be displayed below the source field
    And the error message should say "Source is required"
    And the flow should not be added

  @validation
  Scenario: Flow form validates target is not empty
    Given I am adding a new flow
    When I leave the target field empty
    And I try to submit the form
    Then an error message should be displayed below the target field
    And the error message should say "Target is required"
    And the flow should not be added

  @validation
  Scenario: Flow form validates value is a number
    Given I am adding a new flow
    When I enter "abc" in the value field
    And I try to submit the form
    Then an error message should be displayed below the value field
    And the error message should say "Value must be a number"
    And the flow should not be added

  @validation
  Scenario: Flow form validates value is positive
    Given I am adding a new flow
    When I enter "-100" in the value field
    And I try to submit the form
    Then an error message should be displayed below the value field
    And the error message should say "Value must be positive"
    And the flow should not be added

  @validation
  Scenario: Flow form validates value is not zero
    Given I am adding a new flow
    When I enter "0" in the value field
    And I try to submit the form
    Then an error message should be displayed below the value field
    And the error message should say "Value must be positive"
    And the flow should not be added

  @validation
  Scenario: Flow form shows all validation errors at once
    Given I am adding a new flow
    When I leave all fields empty
    And I try to submit the form
    Then I should see error messages for source, target, and value fields
    And the flow should not be added

  @validation
  Scenario: Flow form clears validation errors on valid input
    Given I am adding a new flow
    And I have validation errors displayed
    When I enter valid values in all fields
    Then the error messages should disappear

  # ============================================
  # NOTIFICATIONS AND FEEDBACK
  # ============================================

  @feedback
  Scenario: Success notification on save
    Given I have a Sankey diagram with changes
    When I click the "Save" button
    Then a success notification should appear
    And the notification should say "Diagram saved successfully"
    And the notification should disappear after 3 seconds

  @feedback
  Scenario: Error notification on failed save
    Given the storage is not accessible
    When I try to save a diagram
    Then an error notification should appear
    And the notification should indicate the storage error
    And the notification should remain visible until dismissed

  @feedback
  Scenario: Loading indicator during save operation
    Given I have a Sankey diagram with many flows
    When I click the "Save" button
    Then a loading indicator should appear
    And the Save button should be disabled
    And when the save completes
    Then the loading indicator should disappear
    And the Save button should be enabled

  @feedback
  Scenario: Confirmation dialog for destructive actions
    Given I have a Sankey diagram
    When I try to delete the diagram
    Then a confirmation dialog should appear
    And the dialog should ask "Are you sure you want to delete this diagram?"
    And I should have to click "Delete" to confirm

  @feedback
  Scenario: Progress indicator for long operations
    Given I am exporting a large diagram
    When the export starts
    Then a progress indicator should appear
    And the progress should update as the export proceeds
    And when the export completes
    Then the progress indicator should disappear

  # ============================================
  # RESPONSIVE DESIGN
  # ============================================

  @responsive
  Scenario: Layout adapts to tablet screen size
    Given the screen width is 768px
    When I open the application
    Then the diagram list should be hidden by default
    And the flow list and viewer should be side by side
    And all content should be accessible

  @responsive
  Scenario: Layout adapts to mobile screen size
    Given the screen width is 480px
    When I open the application
    Then the diagram list should be hidden by default
    And the flow list and viewer should be stacked vertically
    And all content should be accessible via scrolling

  @responsive
  Scenario: Touch support for mobile devices
    Given I am using a touch device
    When I tap on a diagram in the list
    Then the diagram should be selected
    And its flows should be displayed

  @responsive
  Scenario: Scroll behavior on small screens
    Given I have a Sankey diagram with many flows
    And I am on a small screen
    When the content overflows the screen height
    Then a vertical scroll bar should appear
    And I should be able to scroll to see all content

  @responsive
  Scenario: Horizontal scrolling for wide diagrams
    Given I have a Sankey diagram with many nodes arranged horizontally
    And the diagram is wider than the screen
    When I look at the Sankey diagram viewer
    Then a horizontal scroll bar should appear
    And I should be able to scroll horizontally to see all nodes

  # ============================================
  # ACCESSIBILITY
  # ============================================

  @accessibility
  Scenario: Keyboard navigation through all elements
    When I use the Tab key to navigate
    Then I should be able to access all interactive elements
    And the focus should be clearly visible on each element
    And the focus order should be logical

  @accessibility
  Scenario: All interactive elements have labels
    When I inspect the UI
    Then all buttons should have accessible labels
    And all form fields should have associated labels
    And all links should have descriptive text

  @accessibility
  Scenario: Form fields have proper ARIA attributes
    When I inspect the flow form
    Then the source field should have aria-required="true"
    And the target field should have aria-required="true"
    And the value field should have aria-required="true"
    And error messages should be associated with their fields using aria-describedby

  @accessibility
  Scenario: High contrast mode support
    Given I have high contrast mode enabled in my operating system
    When I view the application
    Then all text should have a contrast ratio of at least 4.5:1 against its background
    And all interactive elements should be visible
    And the focus indicator should be visible

  @accessibility
  Scenario: Screen reader announcements
    Given I am using a screen reader
    When I add a new flow
    Then the screen reader should announce "Flow added"
    When I delete a flow
    Then the screen reader should announce "Flow deleted"
    When I select a different diagram
    Then the screen reader should announce the new diagram name

  @accessibility
  Scenario: Skip to main content link
    When I use the Tab key as the first navigation
    Then the first focusable element should be a "Skip to main content" link
    And when I activate it
    Then the focus should move to the main content area
