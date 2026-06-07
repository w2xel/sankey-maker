//! Cucumber BDD tests for Sankey Maker Core
//!
//! This module contains the Cucumber test runner and step definitions
//! for testing the core functionality of Sankey Maker.

use cucumber::{given, then, when, World, Parameter, Table, Value};
use sankey_core::{
    models::{Flow, FlowId, Node, NodeId, SankeyDiagram, SankeyDiagramId},
    state::{AppState, Event},
    update::update_app_state,
    storage::{StorageError, TomlStorage, StorageVersion},
    history::{HistoryEntry, HistoryAction},
};
use std::collections::HashMap;
use uuid::Uuid;

// ============================================
// WORLD STATE
// ============================================

/// World state for Cucumber tests
/// This holds the state that persists between steps in a scenario
#[derive(Debug, Default, World)]
struct SankeyWorld {
    // Application state
    app_state: AppState,
    
    // Test data
    test_diagrams: HashMap<String, SankeyDiagramId>,
    test_flows: HashMap<String, FlowId>,
    test_nodes: HashMap<String, NodeId>,
    
    // Error tracking
    last_error: Option<String>,
    
    // Storage
    storage: Option<TomlStorage>,
    
    // Flags
    auto_save_enabled: bool,
}

// ============================================
// HELPER FUNCTIONS
// ============================================

impl SankeyWorld {
    /// Create a new flow with the given parameters
    fn create_flow(&mut self, source: &str, target: &str, value: f64) -> Flow {
        let flow_id = FlowId::new();
        let source_node_id = self.get_or_create_node_id(source);
        let target_node_id = self.get_or_create_node_id(target);
        
        Flow {
            id: flow_id,
            source: source_node_id,
            target: target_node_id,
            value,
            label: None,
        }
    }
    
    /// Get or create a node ID for the given name
    fn get_or_create_node_id(&mut self, name: &str) -> NodeId {
        if let Some(&node_id) = self.test_nodes.get(name) {
            return node_id;
        }
        
        let node_id = NodeId::new();
        self.test_nodes.insert(name.to_string(), node_id);
        node_id
    }
    
    /// Get the current diagram or create one if none exists
    fn get_or_create_current_diagram(&mut self) -> SankeyDiagramId {
        if let Some(current_id) = self.app_state.current_diagram_id {
            return current_id;
        }
        
        // Create a new diagram
        let diagram_id = SankeyDiagramId::new();
        let diagram = SankeyDiagram::new(diagram_id, "Test Diagram".to_string());
        
        self.app_state.sankey_diagrams.insert(diagram_id, diagram);
        self.app_state.current_diagram_id = Some(diagram_id);
        
        diagram_id
    }
    
    /// Find a diagram by name
    fn find_diagram_by_name(&self, name: &str) -> Option<SankeyDiagramId> {
        self.app_state.sankey_diagrams.iter()
            .find(|(_, diagram)| diagram.name == name)
            .map(|(id, _)| *id)
    }
    
    /// Find a flow by source and target
    fn find_flow_by_source_target(&self, source: &str, target: &str) -> Option<FlowId> {
        if let Some(current_id) = self.app_state.current_diagram_id {
            if let Some(diagram) = self.app_state.sankey_diagrams.get(&current_id) {
                for flow in &diagram.flows {
                    let source_node = diagram.get_node(flow.source).unwrap();
                    let target_node = diagram.get_node(flow.target).unwrap();
                    if source_node.label == source && target_node.label == target {
                        return Some(flow.id);
                    }
                }
            }
        }
        None
    }
}

// ============================================
// STEP DEFINITIONS
// ============================================

// Application State Steps

given!("the application is initialized", |world| {
    world.app_state = AppState::new();
    world.last_error = None;
    world.test_diagrams.clear();
    world.test_flows.clear();
    world.test_nodes.clear();
});

given!("I have {int} Sankey diagrams", |world, count: usize| {
    world.app_state = AppState::new();
    for i in 0..count {
        let diagram_id = SankeyDiagramId::new();
        let diagram = SankeyDiagram::new(diagram_id, format!("Diagram {}", i + 1));
        world.app_state.sankey_diagrams.insert(diagram_id, diagram);
    }
    if count > 0 {
        world.app_state.current_diagram_id = world.app_state.sankey_diagrams.keys().next().copied();
    }
});

given!("I have a new Sankey diagram", |world| {
    let diagram_id = SankeyDiagramId::new();
    let diagram = SankeyDiagram::new(diagram_id, "New Diagram".to_string());
    world.app_state.sankey_diagrams.insert(diagram_id, diagram);
    world.app_state.current_diagram_id = Some(diagram_id);
});

given!("I have a Sankey diagram named \"{string}\"", |world, name: String| {
    let diagram_id = SankeyDiagramId::new();
    let diagram = SankeyDiagram::new(diagram_id, name.clone());
    world.app_state.sankey_diagrams.insert(diagram_id, diagram);
    world.app_state.current_diagram_id = Some(diagram_id);
    world.test_diagrams.insert(name, diagram_id);
});

given!("I have a Sankey diagram with a flow from \"{string}\" to \"{string}\" with value {float}", 
    |world, source: String, target: String, value: f64| {
    let diagram_id = world.get_or_create_current_diagram();
    let flow = world.create_flow(&source, &target, value);
    
    // Add the flow to the diagram
    if let Some(diagram) = world.app_state.sankey_diagrams.get_mut(&diagram_id) {
        diagram.add_flow(flow).unwrap();
    }
});

given!("I have a Sankey diagram with {int} flows", |world, count: usize| {
    let diagram_id = world.get_or_create_current_diagram();
    for i in 0..count {
        let flow = world.create_flow(&format!("Source {}", i), &format!("Target {}", i), 100.0);
        if let Some(diagram) = world.app_state.sankey_diagrams.get_mut(&diagram_id) {
            diagram.add_flow(flow).unwrap();
        }
    }
});

given!("the current diagram is \"{string}\"", |world, name: String| {
    if let Some(diagram_id) = world.find_diagram_by_name(&name) {
        world.app_state.current_diagram_id = Some(diagram_id);
    }
});

given!("auto-save is enabled", |world| {
    world.auto_save_enabled = true;
});

given!("auto-save is disabled", |world| {
    world.auto_save_enabled = false;
});

// When Steps

when!("the application starts", |world| {
    world.app_state = AppState::new();
});

when!("I create a new Sankey diagram named \"{string}\"", |world, name: String| {
    let diagram_id = SankeyDiagramId::new();
    let diagram = SankeyDiagram::new(diagram_id, name.clone());
    world.app_state.sankey_diagrams.insert(diagram_id, diagram);
    world.app_state.current_diagram_id = Some(diagram_id);
    world.test_diagrams.insert(name, diagram_id);
});

when!("I select diagram \"{string}\"", |world, name: String| {
    if let Some(diagram_id) = world.find_diagram_by_name(&name) {
        world.app_state.current_diagram_id = Some(diagram_id);
    }
});

when!("I add a flow from \"{string}\" to \"{string}\" with value {float}", 
    |world, source: String, target: String, value: f64| {
    let diagram_id = world.get_or_create_current_diagram();
    let flow = world.create_flow(&source, &target, value);
    
    let event = Event::AddFlow {
        diagram_id,
        flow,
    };
    
    world.app_state = update_app_state(world.app_state.clone(), event);
});

when!("I try to add a flow from \"{string}\" to \"{string}\" with value {float}", 
    |world, source: String, target: String, value: f64| {
    let diagram_id = world.get_or_create_current_diagram();
    let flow = world.create_flow(&source, &target, value);
    
    let event = Event::AddFlow {
        diagram_id,
        flow,
    };
    
    let old_state = world.app_state.clone();
    world.app_state = update_app_state(old_state, event);
    
    // Check if the flow was actually added
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            let source_node_id = world.get_or_create_node_id(&source);
            let target_node_id = world.get_or_create_node_id(&target);
            
            let flow_exists = diagram.flows.iter().any(|f| {
                f.source == source_node_id && f.target == target_node_id
            });
            
            if !flow_exists {
                world.last_error = Some("Failed to add flow".to_string());
            }
        }
    }
});

when!("I remove the flow from \"{string}\" to \"{string}\"", |world, source: String, target: String| {
    if let Some(flow_id) = world.find_flow_by_source_target(&source, &target) {
        let diagram_id = world.get_or_create_current_diagram();
        let event = Event::RemoveFlow {
            diagram_id,
            flow_id,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I update the flow from \"{string}\" to \"{string}\" to have value {float}", 
    |world, source: String, target: String, new_value: f64| {
    if let Some(flow_id) = world.find_flow_by_source_target(&source, &target) {
        let diagram_id = world.get_or_create_current_diagram();
        let event = Event::UpdateFlowValue {
            diagram_id,
            flow_id,
            new_value,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I update the flow source from \"{string}\" to \"{string}\"", 
    |world, old_source: String, new_source: String| {
    if let Some(flow_id) = world.find_flow_by_source_target(&old_source, &world.app_state.current_diagram_id.map_or("".to_string(), |id| {
        world.app_state.sankey_diagrams.get(&id).and_then(|d| {
            d.flows.iter().find(|f| f.id == flow_id).map(|f| {
                d.get_node(f.target).map_or("".to_string(), |n| n.label.clone())
            })
        }).unwrap_or("".to_string())
    })) {
        let diagram_id = world.get_or_create_current_diagram();
        let new_source_node_id = world.get_or_create_node_id(&new_source);
        let event = Event::UpdateFlowSource {
            diagram_id,
            flow_id,
            new_source: new_source_node_id,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I update the flow target from \"{string}\" to \"{string}\"", 
    |world, old_target: String, new_target: String| {
    if let Some(flow_id) = world.find_flow_by_source_target(&world.app_state.current_diagram_id.map_or("".to_string(), |id| {
        world.app_state.sankey_diagrams.get(&id).and_then(|d| {
            d.flows.iter().find(|f| f.id == flow_id).map(|f| {
                d.get_node(f.source).map_or("".to_string(), |n| n.label.clone())
            })
        }).unwrap_or("".to_string())
    }), &old_target) {
        let diagram_id = world.get_or_create_current_diagram();
        let new_target_node_id = world.get_or_create_node_id(&new_target);
        let event = Event::UpdateFlowTarget {
            diagram_id,
            flow_id,
            new_target: new_target_node_id,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I rename the diagram to \"{string}\"", |world, new_name: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        let event = Event::RenameDiagram {
            diagram_id: current_id,
            new_name,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I delete the diagram \"{string}\"", |world, name: String| {
    if let Some(diagram_id) = world.find_diagram_by_name(&name) {
        let event = Event::DeleteDiagram {
            diagram_id,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I delete the current diagram", |world| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        let event = Event::DeleteDiagram {
            diagram_id: current_id,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

when!("I undo the last action", |world| {
    let event = Event::Undo;
    world.app_state = update_app_state(world.app_state.clone(), event);
});

when!("I redo the last undone action", |world| {
    let event = Event::Redo;
    world.app_state = update_app_state(world.app_state.clone(), event);
});

when!("I save the diagram", |world| {
    // In a real implementation, this would save to storage
    // For testing, we just mark that save was attempted
    if world.auto_save_enabled {
        // Auto-save would happen here
    }
});

when!("I save the diagram as \"{string}\"", |world, name: String| {
    // Rename and save
    if let Some(current_id) = world.app_state.current_diagram_id {
        let event = Event::RenameDiagram {
            diagram_id: current_id,
            new_name: name,
        };
        
        world.app_state = update_app_state(world.app_state.clone(), event);
    }
});

// Then Steps

then!("the application state should be empty", |world| {
    assert!(world.app_state.sankey_diagrams.is_empty());
    assert!(world.app_state.current_diagram_id.is_none());
});

then!("there should be {int} Sankey diagrams", |world, count: usize| {
    assert_eq!(world.app_state.sankey_diagrams.len(), count);
});

then!("the current diagram should be None", |world| {
    assert!(world.app_state.current_diagram_id.is_none());
});

then!("the current diagram should be \"{string}\"", |world, name: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            assert_eq!(diagram.name, name);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("I should have {int} Sankey diagrams", |world, count: usize| {
    assert_eq!(world.app_state.sankey_diagrams.len(), count);
});

then!("the diagram should have {int} flows", |world, count: usize| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            assert_eq!(diagram.flows.len(), count);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the diagram should have {int} nodes", |world, count: usize| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            assert_eq!(diagram.nodes.len(), count);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the diagram should have nodes \"{string}\" and \"{string}\"", |world, node1: String, node2: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            let node_labels: Vec<String> = diagram.nodes.values().map(|n| n.label.clone()).collect();
            assert!(node_labels.contains(&node1));
            assert!(node_labels.contains(&node2));
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the diagram should have nodes \"{string}\"", |world, expected_nodes: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            let node_labels: Vec<String> = diagram.nodes.values().map(|n| n.label.clone()).collect();
            let expected: Vec<String> = expected_nodes.split(", ").map(|s| s.to_string()).collect();
            
            for node in expected {
                assert!(node_labels.contains(&node), "Node {} not found", node);
            }
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the flow should have source \"{string}\"", |world, source: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            if let Some(flow) = diagram.flows.last() {
                let source_node = diagram.get_node(flow.source).unwrap();
                assert_eq!(source_node.label, source);
            } else {
                panic!("No flows in diagram");
            }
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the flow should have target \"{string}\"", |world, target: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            if let Some(flow) = diagram.flows.last() {
                let target_node = diagram.get_node(flow.target).unwrap();
                assert_eq!(target_node.label, target);
            } else {
                panic!("No flows in diagram");
            }
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the flow should have value {float}", |world, value: f64| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            if let Some(flow) = diagram.flows.last() {
                assert!((flow.value - value).abs() < f64::EPSILON);
            } else {
                panic!("No flows in diagram");
            }
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the flow from \"{string}\" to \"{string}\" should have value {float}", 
    |world, source: String, target: String, value: f64| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            for flow in &diagram.flows {
                let source_node = diagram.get_node(flow.source).unwrap();
                let target_node = diagram.get_node(flow.target).unwrap();
                if source_node.label == source && target_node.label == target {
                    assert!((flow.value - value).abs() < f64::EPSILON);
                    return;
                }
            }
            panic!("Flow from {} to {} not found", source, target);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the diagram should be valid", |world| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            assert!(diagram.is_valid());
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the diagram should still have {int} flow from \"{string}\" to \"{string}\"", 
    |world, count: usize, source: String, target: String| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            let matching_flows = diagram.flows.iter().filter(|flow| {
                let source_node = diagram.get_node(flow.source).unwrap();
                let target_node = diagram.get_node(flow.target).unwrap();
                source_node.label == source && target_node.label == target
            }).count();
            
            assert_eq!(matching_flows, count);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

then!("the flow should not be added", |world| {
    assert!(world.last_error.is_some());
});

then!("an error should be returned", |world| {
    assert!(world.last_error.is_some());
});

then!("the diagram should have exactly {int} nodes", |world, count: usize| {
    if let Some(current_id) = world.app_state.current_diagram_id {
        if let Some(diagram) = world.app_state.sankey_diagrams.get(&current_id) {
            assert_eq!(diagram.nodes.len(), count);
        } else {
            panic!("Current diagram not found");
        }
    } else {
        panic!("No current diagram");
    }
});

// ============================================
// CUCUMBER TEST RUNNER
// ============================================

#[cucumber::main]
fn main() {
    // This will run all the feature files
    // The actual feature files are loaded from the tests/features directory
    // and are processed by the cucumber runtime
}

// Note: The actual feature files need to be included in the test binary
// This is done through the build.rs file or by using the cucumber macro

// For now, we'll create a simple test to verify the world works
#[test]
fn test_world_initialization() {
    let world = SankeyWorld::default();
    assert!(world.app_state.sankey_diagrams.is_empty());
    assert!(world.app_state.current_diagram_id.is_none());
}