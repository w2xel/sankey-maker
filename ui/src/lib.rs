//! Yew frontend for Sankey Maker - full Rust web UI

use sankey_core::{Link, Node, SankeyDiagram};
use thiserror::Error;
use uuid::Uuid;
use wasm_bindgen::prelude::*;
use yew::prelude::*;
use yew_router::prelude::*;

/// Errors that can occur in the UI
#[derive(Debug, Error)]
pub enum UiError {
    #[error("Core error: {0}")]
    Core(#[from] sankey_core::CoreError),
    #[error("Rendering error: {0}")]
    Rendering(String),
}

/// Main application component
#[function_component(App)]
pub fn app() -> Html {
    html! {
        <div class="app-container">
            <h1>{ "Sankey Maker" }</h1>
            <p>{ "Loading..." }</p>
        </div>
    }
}

/// Route definitions for the application
#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Home,
    #[at("/diagram/:id")]
    Diagram { id: String },
    #[at("/new")]
    NewDiagram,
    #[not_found]
    #[at("/404")]
    NotFound,
}

/// Switch component for routing
#[function_component(Main)]
pub fn main_component() -> Html {
    html! {
        <BrowserRouter>
            <Switch<Route> render={switch} />
        </BrowserRouter>
    }
}

fn switch(routes: Route) -> Html {
    match routes {
        Route::Home => html! { <App /> },
        Route::Diagram { id } => html! { <div>{ format!("Diagram: {}", id) }</div> },
        Route::NewDiagram => html! { <div>{ "New Diagram" }</div> },
        Route::NotFound => html! { <div>{ "404 - Not Found" }</div> },
    }
}

/// Home page component
#[function_component(Home)]
pub fn home() -> Html {
    html! { <App /> }
}

/// Diagram editor component
#[function_component(DiagramEditor)]
pub fn diagram_editor() -> Html {
    html! { <div>{ "Diagram Editor" }</div> }
}

/// Diagram viewer component
#[function_component(DiagramViewer)]
pub fn diagram_viewer() -> Html {
    html! { <div>{ "Diagram Viewer" }</div> }
}

/// Node editor component
#[derive(Properties, PartialEq)]
pub struct NodeEditorProps {
    pub node: Node,
    pub on_update: Callback<Node>,
    pub on_delete: Callback<Uuid>,
}

#[function_component(NodeEditor)]
pub fn node_editor(_props: &NodeEditorProps) -> Html {
    html! { <div>{ "Node Editor" }</div> }
}

/// Link editor component
#[derive(Properties, PartialEq)]
pub struct LinkEditorProps {
    pub link: Link,
    pub nodes: Vec<Node>,
    pub on_update: Callback<Link>,
    pub on_delete: Callback<Uuid>,
}

#[function_component(LinkEditor)]
pub fn link_editor(_props: &LinkEditorProps) -> Html {
    html! { <div>{ "Link Editor" }</div> }
}

/// SVG renderer component for Sankey diagrams
#[derive(Properties, PartialEq)]
pub struct SankeyRendererProps {
    pub diagram: SankeyDiagram,
    pub width: u32,
    pub height: u32,
}

#[function_component(SankeyRenderer)]
pub fn sankey_renderer(_props: &SankeyRendererProps) -> Html {
    html! { <div>{ "Sankey Renderer" }</div> }
}

/// Toolbar component
#[function_component(Toolbar)]
pub fn toolbar() -> Html {
    html! { <div>{ "Toolbar" }</div> }
}

/// Export functionality
pub fn export_diagram(diagram: &SankeyDiagram) -> Result<String, UiError> {
    sankey_core::serialize_diagram(diagram).map_err(UiError::Core)
}

/// Import functionality
pub fn import_diagram(json: &str) -> Result<SankeyDiagram, UiError> {
    sankey_core::deserialize_diagram(json).map_err(UiError::Core)
}

/// Download diagram as file
pub fn download_diagram(_diagram: &SankeyDiagram, _filename: &str) {
    // TODO: Implement file download
}

/// Upload diagram from file
pub async fn upload_diagram() -> Option<SankeyDiagram> {
    // TODO: Implement file upload
    None
}

/// Entry point for the WASM application
#[wasm_bindgen(start)]
pub fn main() {
    // Initialize panic hook for better error messages
    console_error_panic_hook::set_once();

    // Initialize logging
    console_log::init_with_level(log::Level::Trace).unwrap();

    log::info!("Sankey Maker WASM initialized");

    // Mount the app - render the main component
    yew::Renderer::<Main>::new().render();
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_export_import() {
        // Test will be implemented when UI functions are complete
    }
}
