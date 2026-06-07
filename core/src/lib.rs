//! Core logic for Sankey Maker - pure functional state management

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;
use uuid::Uuid;

/// Represents a node in a Sankey diagram
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Node {
    pub id: Uuid,
    pub name: String,
}

/// Represents a link between nodes in a Sankey diagram
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Link {
    pub id: Uuid,
    pub source: Uuid,
    pub target: Uuid,
    pub value: f64,
}

/// Represents a complete Sankey diagram
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct SankeyDiagram {
    pub nodes: Vec<Node>,
    pub links: Vec<Link>,
}

/// Application state
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppState {
    pub diagrams: HashMap<Uuid, SankeyDiagram>,
    pub current_diagram_id: Option<Uuid>,
}

/// Errors that can occur in the core logic
#[derive(Debug, Error)]
pub enum CoreError {
    #[error("Node not found: {0}")]
    NodeNotFound(Uuid),
    #[error("Link not found: {0}")]
    LinkNotFound(Uuid),
    #[error("Diagram not found: {0}")]
    DiagramNotFound(Uuid),
    #[error("Invalid link: source and target must be different")]
    InvalidLink,
    #[error("Serialization error: {0}")]
    SerializationError(String),
}

/// Create a new Sankey diagram
pub fn create_diagram() -> SankeyDiagram {
    SankeyDiagram {
        nodes: Vec::new(),
        links: Vec::new(),
    }
}

/// Add a node to a diagram
pub fn add_node(diagram: &mut SankeyDiagram, name: String) -> Node {
    let node = Node {
        id: Uuid::new_v4(),
        name,
    };
    diagram.nodes.push(node.clone());
    node
}

/// Add a link between two nodes
pub fn add_link(
    diagram: &mut SankeyDiagram,
    source_id: Uuid,
    target_id: Uuid,
    value: f64,
) -> Result<Link, CoreError> {
    if source_id == target_id {
        return Err(CoreError::InvalidLink);
    }

    let node_ids: Vec<Uuid> = diagram.nodes.iter().map(|n| n.id).collect();
    if !node_ids.contains(&source_id) || !node_ids.contains(&target_id) {
        return Err(CoreError::NodeNotFound(source_id));
    }

    let link = Link {
        id: Uuid::new_v4(),
        source: source_id,
        target: target_id,
        value,
    };
    diagram.links.push(link.clone());
    Ok(link)
}

/// Remove a node from a diagram
pub fn remove_node(diagram: &mut SankeyDiagram, node_id: Uuid) -> Result<Node, CoreError> {
    let index = diagram
        .nodes
        .iter()
        .position(|n| n.id == node_id)
        .ok_or(CoreError::NodeNotFound(node_id))?;
    Ok(diagram.nodes.remove(index))
}

/// Remove a link from a diagram
pub fn remove_link(diagram: &mut SankeyDiagram, link_id: Uuid) -> Result<Link, CoreError> {
    let index = diagram
        .links
        .iter()
        .position(|l| l.id == link_id)
        .ok_or(CoreError::LinkNotFound(link_id))?;
    Ok(diagram.links.remove(index))
}

/// Serialize a diagram to JSON
pub fn serialize_diagram(diagram: &SankeyDiagram) -> Result<String, CoreError> {
    serde_json::to_string(diagram).map_err(|e| CoreError::SerializationError(e.to_string()))
}

/// Deserialize a diagram from JSON
pub fn deserialize_diagram(json: &str) -> Result<SankeyDiagram, CoreError> {
    serde_json::from_str(json).map_err(|e| CoreError::SerializationError(e.to_string()))
}

/// Validate a diagram (check for orphaned links, etc.)
pub fn validate_diagram(diagram: &SankeyDiagram) -> Result<(), CoreError> {
    let node_ids: Vec<Uuid> = diagram.nodes.iter().map(|n| n.id).collect();
    for link in &diagram.links {
        if !node_ids.contains(&link.source) || !node_ids.contains(&link.target) {
            return Err(CoreError::NodeNotFound(link.source));
        }
        if link.source == link.target {
            return Err(CoreError::InvalidLink);
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_diagram() {
        let _diagram = create_diagram();
    }

    #[test]
    fn test_add_node() {
        let mut diagram = create_diagram();
        let _node = add_node(&mut diagram, "Test".to_string());
    }

    #[test]
    fn test_add_link() {
        let mut diagram = create_diagram();
        let node1 = add_node(&mut diagram, "Node1".to_string());
        let node2 = add_node(&mut diagram, "Node2".to_string());
        let _link = add_link(&mut diagram, node1.id, node2.id, 10.0);
    }

    #[test]
    fn test_serialize_deserialize() {
        let diagram = create_diagram();
        let _json = serialize_diagram(&diagram);
    }
}
