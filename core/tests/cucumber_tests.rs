//! Cucumber BDD tests for Sankey Maker Core

use cucumber::{given, then, when, World};
use sankey_core::{Node, SankeyDiagram};

/// World state for Cucumber tests
#[derive(Debug, Default, World)]
struct SankeyWorld {
    diagram: Option<SankeyDiagram>,
    nodes: Vec<Node>,
}

given!("I have an empty diagram", |world| {
    world.diagram = Some(sankey_core::create_diagram());
});

when!("I add a node", |world| {
    todo!();
});

then!("the diagram should have nodes", |world| {
    todo!();
});

#[cucumber::main]
fn main() {
    todo!();
}
