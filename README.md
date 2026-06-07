# Sankey Maker

> **A pure-Rust application for creating Sankey diagrams for personal finance**

Sankey Maker is a cross-platform application that allows you to create, edit, and visualize Sankey diagrams specifically designed for personal finance tracking. Built entirely in Rust with a functional architecture, it offers both desktop and web deployment options.

## Features

- **Pure Functional Architecture**: State management follows functional programming principles with immutable state updates
- **Full Rust Stack**: Uses Yew for the frontend, ensuring type safety throughout the entire application
- **Implicit Node Creation**: Create flows between entities without explicitly creating nodes first
- **Versioned Storage**: TOML-based storage with versioning support for backward compatibility
- **History Tracking**: Complete history of all changes for undo/redo functionality
- **Multiple Export Formats**: Export diagrams as PNG, SVG, and other formats
- **Cross-Platform**: Deploy as desktop app (Tauri) or client-side web app
- **Comprehensive Testing**: Unit tests, integration tests, and BDD tests using Cucumber

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SANKEY MAKER ARCHITECTURE                   │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Yew UI    │───▶│  Core Logic │───▶│  Charming       │  │
│  │ (Frontend)  │    │ (Pure Rust) │    │  Wrapper        │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│          ▲                  │                  ▲              │
│          │                  ▼                  │              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │  User       │    │  TOML       │    │  Diagram        │  │
│  │  Actions    │    │  Storage    │    │  Rendering      │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

1. **Core Library (`core/`)**
   - Pure functional state management
   - Domain models (Flow, Node, SankeyDiagram)
   - Event handling and state updates
   - TOML storage with versioning
   - History tracking

2. **Charming Wrapper (`charming-wrapper/`)**
   - Abstraction layer for the `charming` library
   - Diagram rendering interface
   - Export functionality (PNG, SVG)

3. **UI (`ui/`)**
   - Yew-based frontend
   - Three-column layout
   - Responsive design
   - Real-time updates

## Project Structure

```
sankey-maker/
├── core/                    # Pure Rust logic
│   ├── src/
│   │   ├── lib.rs           # Core library exports
│   │   ├── state.rs         # AppState and Event definitions
│   │   ├── models.rs        # Flow, Node, SankeyDiagram models
│   │   ├── update.rs        # Pure update functions
│   │   ├── storage.rs       # TOML storage with versioning
│   │   └── history.rs       # History management
│   └── Cargo.toml
│
├── charming-wrapper/        # Charming library abstraction
│   ├── src/
│   │   └── lib.rs           # Wrapper implementation
│   └── Cargo.toml
│
├── ui/                      # Yew frontend
│   ├── src/
│   │   ├── main.rs          # Application entry point
│   │   ├── app.rs           # Main app component
│   │   ├── components/
│   │   │   ├── diagram_list.rs  # Left column - diagram list
│   │   │   ├── flow_list.rs     # Middle column - flow list
│   │   │   ├── sankey_viewer.rs  # Right column - Sankey viewer
│   │   │   └── ...
│   │   ├── hooks/           # Custom Yew hooks
│   │   ├── tests/           # UI unit tests
│   │   └── styles/          # CSS styling
│   ├── index.html
│   ├── package.json
│   ├── Trunk.toml
│   └── Cargo.toml
│
├── tests/                   # Integration and BDD tests
│   ├── features/            # Cucumber feature files
│   │   ├── core.feature
│   │   ├── ui.feature
│   │   └── storage.feature
│   └── steps/               # Cucumber step definitions
│       ├── core_steps.rs
│       ├── ui_steps.rs
│       └── storage_steps.rs
│
├── .github/
│   └── workflows/
│       ├── ci.yml           # Continuous Integration
│       └── release.yml      # Release workflow
│
├── Cargo.toml               # Workspace configuration
└── README.md
```

## Getting Started

### Prerequisites

- Rust (latest stable version)
- Node.js (for Trunk and WASM tooling)
- Cargo (Rust package manager)

### Installation

```bash
# Clone the repository
git clone https://github.com/w2xel/sankey-maker.git
cd sankey-maker

# Install Trunk for WASM bundling
cargo install trunk

# Install wasm-pack
cargo install wasm-pack

# Install dependencies
cd ui
npm install
cd ..
```

### Running the Application

#### Development Mode

```bash
cd ui
trunk serve --open
```

This will start a development server at `http://localhost:8080` with hot reloading.

#### Production Build

```bash
cd ui
trunk build --release
```

The optimized build will be available in the `dist/` directory.

### Running Tests

```bash
# Run all tests
cargo test --workspace

# Run with all features
cargo test --all-features --workspace

# Run clippy
cargo clippy --all-targets --all-features -- -D warnings

# Run formatting check
cargo fmt --all -- --check

# Run Cucumber BDD tests
cargo test --features testing --test cucumber_tests
```

## Usage

### Creating a Sankey Diagram

1. **Create Flows**: Simply add a flow from source to target with a value
   - Example: "Salary → Rent: $1000"
   - Nodes (Salary, Rent) are created automatically

2. **Edit Flows**: Modify existing flows by changing source, target, or value

3. **Remove Flows**: Delete flows when no longer needed

4. **Organize**: Create multiple Sankey diagrams for different time periods or categories

### UI Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [☰] Sankey Maker                    [New] [Save] [Export]   │
├─────────────┬─────────────────────┬─────────────────────────┤
│             │                     │                         │
│  DIAGRAMS   │    FLOWS            │    SANKEY VIEWER        │
│  ┌───────┐  │  ┌───────────────┐  │  ┌───────────────────┐  │
│  │Diagram│  │  │Salary → Rent   │  │  │    [SVG Diagram]   │  │
│  │  1    │  │  │  $1000        │  │  │                   │  │
│  │Diagram│  │  │Salary → Food   │  │  │    [Interactive]   │  │
│  │  2    │  │  │  $500         │  │  │                   │  │
│  │+ New  │  │  │+ Add Flow     │  │  │                   │  │
│  └───────┘  │  └───────────────┘  │  └───────────────────┘  │
│             │                     │                         │
└─────────────┴─────────────────────┴─────────────────────────┘
```

- **Left Column**: List of Sankey diagrams (can be hidden)
- **Middle Column**: List of flows in the current diagram
- **Right Column**: Large area for the rendered Sankey diagram

### Keyboard Shortcuts

- `Ctrl+N`: New diagram
- `Ctrl+S`: Save current diagram
- `Ctrl+E`: Export current diagram
- `Ctrl+Z`: Undo last action
- `Ctrl+Y`: Redo last action
- `Delete`: Remove selected flow

## Storage Format

Sankey Maker uses TOML for storage with versioning support:

```toml
[metadata]
version = 1
created_at = "2024-01-01T00:00:00Z"
app_version = "0.1.0"

[[diagrams]]
id = "diagram_1"
name = "January 2024"
created_at = "2024-01-01T00:00:00Z"
updated_at = "2024-01-01T00:00:00Z"

[[diagrams.flows]]
id = "flow_1"
source = "Salary"
target = "Rent"
value = 1000.0
label = "Monthly Rent"

[[diagrams.flows]]
id = "flow_2"
source = "Salary"
target = "Food"
value = 500.0

[[history]]
timestamp = "2024-01-01T00:00:00Z"
action = "create_diagram"
diagram_id = "diagram_1"

[[history]]
timestamp = "2024-01-01T00:01:00Z"
action = "add_flow"
flow_id = "flow_1"
diagram_id = "diagram_1"

[[history]]
timestamp = "2024-01-01T00:02:00Z"
action = "add_flow"
flow_id = "flow_2"
diagram_id = "diagram_1"
```

### Version Compatibility

The storage format is versioned to ensure backward compatibility:

- **Version 1**: Initial format (current)
- **Future versions**: Will include migration logic

## Export Formats

- **PNG**: High-resolution raster images
- **SVG**: Scalable vector graphics
- **JSON**: For interoperability with other tools
- **TOML**: Native format for backup and sharing

## Testing

Sankey Maker uses multiple testing approaches:

### 1. Unit Tests

```bash
cargo test --workspace
```

### 2. Integration Tests

```bash
cargo test --test integration_tests
```

### 3. BDD Tests (Cucumber)

```bash
cargo test --features testing --test cucumber_tests
```

Feature files are located in `tests/features/` and use Gherkin syntax:

```gherkin
Feature: Flow Management
  As a user
  I want to add flows to my Sankey diagram
  So that I can track my financial transactions

  Scenario: Adding a new flow
    Given I have a new Sankey diagram
    When I add a flow from "Salary" to "Rent" with value 1000
    Then the diagram should have 1 flow
    And the diagram should have nodes "Salary" and "Rent"
```

## Configuration

### Environment Variables

- `RUST_LOG`: Set logging level (debug, info, warn, error)
- `SANKEY_STORAGE_PATH`: Custom path for storing diagrams

### Build Configuration

Edit `Cargo.toml` files to customize dependencies and features.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Rust naming conventions
- Use `clippy` and `rustfmt` to maintain code quality
- Add tests for new functionality
- Update documentation as needed
- Keep commits atomic and well-described

### Code Style

```bash
# Format code
cargo fmt --all

# Check for linting issues
cargo clippy --all-targets --all-features -- -D warnings

# Run all tests
cargo test --all-features --workspace
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Yew](https://yew.rs/) - Rust framework for creating multi-threaded frontend apps
- [Charming](https://crates.io/crates/charming) - Sankey diagram generation library
- [Cucumber](https://cucumber.io/) - BDD testing framework
- [Trunk](https://trunkrs.dev/) - WASM bundler for Rust web apps

## Roadmap

- [ ] Core functionality (MVP)
- [ ] Tauri desktop app support
- [ ] Advanced diagram customization
- [ ] Cloud sync functionality
- [ ] Collaborative editing
- [ ] Mobile support

---

**Sankey Maker** - Making personal finance visualization simple and powerful.

*Built with ❤️ in Rust*