# language: en
@storage
Feature: Storage Functionality
  As a user of Sankey Maker
  I want my diagrams to be saved and loaded correctly
  So that I can persist my work and continue later

  Background:
    Given the application is initialized

  # ============================================
  # SAVING DIAGRAMS
  # ============================================

  @saving
  Scenario: Saving a new diagram
    Given I have a new Sankey diagram named "Test Diagram"
    When I save the diagram
    Then the diagram should be saved to storage
    And I should be able to load the diagram

  @saving
  Scenario: Saving a diagram with flows
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And I have a flow from "B" to "C" with value 50
    When I save the diagram as "Flow Diagram"
    Then the diagram should be saved with all flows
    And when I load "Flow Diagram"
    Then it should have 2 flows
    And it should have nodes "A", "B", and "C"

  @saving
  Scenario: Saving multiple diagrams
    Given I have a Sankey diagram named "Diagram 1" with a flow from "A" to "B" with value 100
    And I have a Sankey diagram named "Diagram 2" with a flow from "X" to "Y" with value 200
    When I save all diagrams
    Then both diagrams should be saved
    And when I reload the application
    Then I should have 2 diagrams

  @saving
  Scenario: Overwriting an existing diagram
    Given I have a Sankey diagram named "Existing" with a flow from "A" to "B" with value 100
    And the diagram is saved
    When I add a flow from "C" to "D" with value 200
    And I save the diagram
    Then the saved diagram should have 2 flows
    And the old version should be replaced

  # ============================================
  # LOADING DIAGRAMS
  # ============================================

  @loading
  Scenario: Loading a saved diagram
    Given I have saved a Sankey diagram named "Saved Diagram" with a flow from "A" to "B" with value 100
    When I load "Saved Diagram"
    Then I should have 1 Sankey diagram
    And the current diagram should be "Saved Diagram"
    And it should have 1 flow from "A" to "B" with value 100

  @loading
  Scenario: Loading a non-existent diagram
    When I try to load "Non Existent"
    Then an error should be returned
    And no diagram should be loaded

  @loading
  Scenario: Loading diagram with invalid format
    Given I have a corrupted storage file
    When I try to load the corrupted file
    Then an error should be returned
    And the application state should remain unchanged

  @loading
  Scenario: Loading multiple diagrams
    Given I have saved 3 diagrams: "Diagram 1", "Diagram 2", "Diagram 3"
    When I load all diagrams
    Then I should have 3 Sankey diagrams

  # ============================================
  # TOML STORAGE FORMAT
  # ============================================

  @toml
  Scenario: Diagram is saved in TOML format
    Given I have a Sankey diagram named "TOML Test" with a flow from "Source" to "Target" with value 100
    When I save the diagram
    Then the storage file should be valid TOML
    And the TOML should contain the diagram name
    And the TOML should contain the flow data

  @toml
  Scenario: TOML file contains metadata
    Given I have a Sankey diagram
    When I save the diagram
    Then the TOML file should contain metadata
    And the metadata should include version information
    And the metadata should include creation timestamp

  @toml
  Scenario: TOML file contains history
    Given I have a Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I remove the flow from "A" to "B"
    When I save the diagram
    Then the TOML file should contain history entries
    And the history should include the add_flow action
    And the history should include the remove_flow action

  # ============================================
  # VERSION COMPATIBILITY
  # ============================================

  @versioning
  Scenario: Loading current version TOML
    Given I have a TOML file with version 1
    When I load the TOML file
    Then it should load successfully
    And all data should be preserved

  @versioning
  Scenario: Loading older version TOML
    Given I have a TOML file with version 0
    When I load the TOML file
    Then it should load successfully
    And the data should be migrated to current version

  @versioning
  Scenario: Loading future version TOML
    Given I have a TOML file with version 2
    When I try to load the TOML file
    Then an error should be returned
    And a message should indicate the version is not supported

  @versioning
  Scenario: Version migration preserves data
    Given I have a TOML file with version 0 containing a flow from "A" to "B" with value 100
    When I load the TOML file
    Then the diagram should have 1 flow from "A" to "B" with value 100
    And the loaded diagram should be version 1

  # ============================================
  # EXPORT FUNCTIONALITY
  # ============================================

  @export
  Scenario: Exporting diagram to TOML
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I export the diagram to TOML
    Then a TOML file should be created
    And the TOML file should contain the diagram data

  @export
  Scenario: Exporting diagram to JSON
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I export the diagram to JSON
    Then a JSON file should be created
    And the JSON file should contain the diagram data

  @export
  Scenario: Exporting multiple diagrams
    Given I have 2 Sankey diagrams
    When I export all diagrams
    Then all diagrams should be included in the export

  # ============================================
  # IMPORT FUNCTIONALITY
  # ============================================

  @import
  Scenario: Importing diagram from TOML
    Given I have a TOML file with a Sankey diagram
    When I import the TOML file
    Then the diagram should be added to my diagrams
    And I should be able to edit the imported diagram

  @import
  Scenario: Importing diagram from JSON
    Given I have a JSON file with a Sankey diagram
    When I import the JSON file
    Then the diagram should be added to my diagrams

  @import
  Scenario: Importing invalid file
    Given I have an invalid file
    When I try to import the file
    Then an error should be returned
    And no diagram should be added

  @import
  Scenario: Importing file with duplicate diagram name
    Given I have a Sankey diagram named "Existing"
    And I have a TOML file with a diagram named "Existing"
    When I import the TOML file
    Then the imported diagram should have a unique name
    Or I should be prompted to choose a new name

  # ============================================
  # FILE OPERATIONS
  # ============================================

  @files
  Scenario: Saving to specific file path
    Given I have a Sankey diagram
    When I save the diagram to "/path/to/file.toml"
    Then the file should be created at "/path/to/file.toml"

  @files
  Scenario: Loading from specific file path
    Given I have a TOML file at "/path/to/file.toml"
    When I load the file from "/path/to/file.toml"
    Then the diagram should be loaded from that file

  @files
  Scenario: Handling file system errors
    Given the file system is not accessible
    When I try to save a diagram
    Then an error should be returned
    And the application state should remain unchanged

  # ============================================
  # AUTO-SAVE
  # ============================================

  @autosave
  Scenario: Auto-save on changes
    Given I have auto-save enabled
    And I have a Sankey diagram
    When I add a flow from "A" to "B" with value 100
    Then the diagram should be automatically saved

  @autosave
  Scenario: Auto-save disabled
    Given I have auto-save disabled
    And I have a Sankey diagram
    When I add a flow from "A" to "B" with value 100
    Then the diagram should not be automatically saved

  @autosave
  Scenario: Manual save when auto-save is enabled
    Given I have auto-save enabled
    And I have a Sankey diagram
    When I make changes and manually save
    Then the diagram should be saved immediately

  # ============================================
  # BACKUP AND RECOVERY
  # ============================================

  @backup
  Scenario: Creating backup before save
    Given I have a Sankey diagram
    And I have made changes
    When I save the diagram
    Then a backup should be created
    And I should be able to restore from backup

  @backup
  Scenario: Recovering from corrupted file
    Given I have a corrupted storage file
    And I have a backup file
    When I try to load the corrupted file
    Then the application should detect the corruption
    And offer to restore from backup

  @backup
  Scenario: Multiple backup versions
    Given I have made multiple saves
    Then multiple backup versions should exist
    And I should be able to restore from any backup version