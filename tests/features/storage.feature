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

  @saving
  Scenario: Saving diagram with unsaved changes
    Given I have a Sankey diagram named "Test" with a flow from "A" to "B" with value 100
    And the diagram is saved
    When I add a flow from "C" to "D" with value 200
    And I save the diagram
    Then the saved diagram should have 2 flows

  @saving
  Scenario: Saving diagram without changes does not modify file
    Given I have a Sankey diagram named "Test" with a flow from "A" to "B" with value 100
    And the diagram is saved
    When I save the diagram again without making changes
    Then the file modification timestamp should not change

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
    Then an error should be returned with message "Diagram not found"
    And no diagram should be loaded

  @loading
  Scenario: Loading diagram with invalid format
    Given I have a corrupted storage file
    When I try to load the corrupted file
    Then an error should be returned with message indicating the format error
    And the application state should remain unchanged

  @loading
  Scenario: Loading multiple diagrams
    Given I have saved 3 diagrams: "Diagram 1", "Diagram 2", "Diagram 3"
    When I load all diagrams
    Then I should have 3 Sankey diagrams

  @loading
  Scenario: Loading diagram preserves history
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    And I have made changes and saved
    When I load the diagram
    Then the diagram should have the flow from "A" to "B"
    And the history should be preserved

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
    And the metadata should include last modified timestamp

  @toml
  Scenario: TOML file contains history
    Given I have a Sankey diagram
    And I add a flow from "A" to "B" with value 100
    And I remove the flow from "A" to "B"
    When I save the diagram
    Then the TOML file should contain history entries
    And the history should include the add_flow action
    And the history should include the remove_flow action

  @toml
  Scenario: TOML file structure is consistent
    Given I have a Sankey diagram with flows and nodes
    When I save the diagram
    Then the TOML file should have a consistent structure
    And the structure should match the expected schema

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
    And the loaded diagram should be version 1

  @versioning
  Scenario: Loading future version TOML
    Given I have a TOML file with version 2
    When I try to load the TOML file
    Then an error should be returned
    And a message should indicate the version is not supported
    And the message should say "Unsupported version: 2"

  @versioning
  Scenario: Version migration preserves data
    Given I have a TOML file with version 0 containing a flow from "A" to "B" with value 100
    When I load the TOML file
    Then the diagram should have 1 flow from "A" to "B" with value 100
    And the loaded diagram should be version 1

  @versioning
  Scenario: Version migration handles missing fields
    Given I have a TOML file with version 0 that is missing some fields
    When I load the TOML file
    Then missing fields should be filled with default values
    And the diagram should load successfully

  @versioning
  Scenario: Version migration preserves unknown fields
    Given I have a TOML file with version 0 containing custom fields
    When I load the TOML file
    Then the custom fields should be preserved in the loaded data
    And the diagram should load successfully

  # ============================================
  # EXPORT FUNCTIONALITY
  # ============================================

  @export
  Scenario Outline: Exporting diagram to various formats
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I export the diagram to <format>
    Then a <format> file should be created
    And the <format> file should contain the diagram data

    Examples:
      | format |
      | TOML   |
      | JSON   |

  @export
  Scenario: Exporting diagram to TOML preserves structure
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I export the diagram to TOML
    Then a TOML file should be created
    And the TOML file should be valid
    And the TOML file should contain the diagram name
    And the TOML file should contain the flow data

  @export
  Scenario: Exporting diagram to JSON
    Given I have a Sankey diagram with a flow from "A" to "B" with value 100
    When I export the diagram to JSON
    Then a JSON file should be created
    And the JSON file should be valid
    And the JSON file should contain the diagram data

  @export
  Scenario: Exporting multiple diagrams to single file
    Given I have 2 Sankey diagrams
    When I export all diagrams to TOML
    Then a single TOML file should be created
    And the TOML file should contain both diagrams

  @export
  Scenario: Exporting diagram with custom filename
    Given I have a Sankey diagram named "My Diagram"
    When I export the diagram to TOML with filename "Custom Name"
    Then the file should be named "Custom Name.toml"

  @export
  Scenario: Export fails when file system is not accessible
    Given the file system is not accessible
    When I try to export a diagram
    Then an error should be returned
    And the error should indicate the file system error

  # ============================================
  # IMPORT FUNCTIONALITY
  # ============================================

  @import
  Scenario Outline: Importing diagram from various formats
    Given I have a <format> file with a Sankey diagram
    When I import the <format> file
    Then the diagram should be added to my diagrams
    And I should be able to edit the imported diagram

    Examples:
      | format |
      | TOML   |
      | JSON   |

  @import
  Scenario: Importing TOML file with multiple diagrams
    Given I have a TOML file with 3 Sankey diagrams
    When I import the TOML file
    Then all 3 diagrams should be added to my diagrams

  @import
  Scenario: Importing invalid file
    Given I have an invalid file
    When I try to import the file
    Then an error should be returned
    And the error should explain why the import failed
    And no diagram should be added

  @import
  Scenario: Importing file with duplicate diagram name
    Given I have a Sankey diagram named "Existing"
    And I have a TOML file with a diagram named "Existing"
    When I import the TOML file
    Then the imported diagram should have a unique name
    And the unique name should be "Existing (1)" or similar

  @import
  Scenario: Importing file with version mismatch
    Given I have a TOML file with version 2
    When I try to import the file
    Then an error should be returned
    And the error should indicate the version is not supported
    And no diagram should be added

  @import
  Scenario: Importing large file shows progress
    Given I have a large TOML file with many diagrams
    When I import the file
    Then a progress indicator should appear
    And the progress should update as the import proceeds

  # ============================================
  # FILE OPERATIONS
  # ============================================

  @files
  Scenario: Saving to specific file path
    Given I have a Sankey diagram
    When I save the diagram to "/path/to/file.toml"
    Then the file should be created at "/path/to/file.toml"
    And the file should contain the diagram data

  @files
  Scenario: Loading from specific file path
    Given I have a TOML file at "/path/to/file.toml"
    When I load the file from "/path/to/file.toml"
    Then the diagram should be loaded from that file

  @files
  Scenario: Handling file system errors on save
    Given the file system is not accessible
    When I try to save a diagram
    Then an error should be returned
    And the error should indicate the file system error
    And the application state should remain unchanged

  @files
  Scenario: Handling file system errors on load
    Given the file system is not accessible
    When I try to load a diagram
    Then an error should be returned
    And the error should indicate the file system error
    And the application state should remain unchanged

  @files
  Scenario: Handling permission errors
    Given I do not have write permission to the storage directory
    When I try to save a diagram
    Then an error should be returned
    And the error should indicate the permission error

  @files
  Scenario: Handling disk full errors
    Given the disk is full
    When I try to save a diagram
    Then an error should be returned
    And the error should indicate the disk is full

  # ============================================
  # AUTO-SAVE
  # ============================================

  @autosave
  Scenario: Auto-save on changes when enabled
    Given I have auto-save enabled
    And I have a Sankey diagram
    When I add a flow from "A" to "B" with value 100
    Then the diagram should be automatically saved within 1 second

  @autosave
  Scenario: Auto-save disabled does not save automatically
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

  @autosave
  Scenario: Auto-save can be configured with delay
    Given I have auto-save enabled with a 5 second delay
    And I have a Sankey diagram
    When I make a change
    Then the diagram should be saved after 5 seconds of inactivity

  @autosave
  Scenario: Auto-save does not save if no changes
    Given I have auto-save enabled
    And I have a Sankey diagram
    When I view the diagram without making changes
    Then the diagram should not be saved

  # ============================================
  # BACKUP AND RECOVERY
  # ============================================

  @backup
  Scenario: Creating backup before save
    Given I have a Sankey diagram
    And I have made changes
    When I save the diagram
    Then a backup should be created
    And the backup should be stored in a separate location

  @backup
  Scenario: Backup file has timestamp in name
    Given I have a Sankey diagram
    When I save the diagram
    Then a backup file should be created
    And the backup filename should include a timestamp

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
    And each backup should have a unique timestamp

  @backup
  Scenario: Restoring from specific backup version
    Given I have multiple backup versions
    When I select a specific backup version to restore
    Then the application should restore from that version
    And the restored data should match the backup

  @backup
  Scenario: Backup retention policy
    Given I have 10 backup versions
    And the retention policy is to keep 5 backups
    When I save the diagram
    Then the oldest backups should be deleted
    And only the 5 most recent backups should remain

  @backup
  Scenario: Backup fails when no space
    Given the disk is full
    When I try to save a diagram
    Then the backup should fail
    And an error should be returned
    And the original file should not be modified

  # ============================================
  # STORAGE LOCATION
  # ============================================

  @location
  Scenario: Default storage location
    Given I have not configured a custom storage location
    When I save a diagram
    Then the diagram should be saved to the default storage location

  @location
  Scenario: Custom storage location
    Given I have configured a custom storage location "/custom/path"
    When I save a diagram
    Then the diagram should be saved to "/custom/path"

  @location
  Scenario: Storage location can be changed
    Given I have diagrams saved to the default location
    When I change the storage location to "/new/path"
    And I save a diagram
    Then the diagram should be saved to "/new/path"
    And the old diagrams should remain in the default location

  @location
  Scenario: Invalid storage location shows error
    Given I have configured an invalid storage location "/invalid/path"
    When I try to save a diagram
    Then an error should be returned
    And the error should indicate the path is invalid
