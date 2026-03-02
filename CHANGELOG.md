# Changelog

## [1.1.0] - 2026-03-02

### Fixed
- CDN resilience: added automatic fallback from jsdelivr to unpkg for all external scripts and stylesheets
- Install script: replaced PyYAML-based docker-compose patching with sed-based approach to preserve original YAML formatting

### Added
- Install script: `--yes` / `-y` flag for non-interactive (CI/SSH) installations
- Install script: automatic CSP (Content Security Policy) detection and fix instructions
- README: comprehensive CSP configuration section with examples for Caddy, Nginx, and Apache

### Changed
- Install script version bumped to v1.1

## [1.0.0] - 2026-03-01

### Added
- **Bot Builder** — Visual drag & drop bot flow editor with 18 node types
- **Campaign Report** — WhatsApp campaign analytics dashboard with CSV export
- **Navigation Widget** — Slide-out sidebar for quick access from all Chatwoot pages
- **Install Script** — One-command automated installation with Docker support
- Bot execution engine (processes flows on incoming messages)
- Dark mode support (auto-detects Chatwoot theme)
- Undo/Redo stack (30 steps)
- Auto-align (BFS layer-based)
- Snap-to-grid (24px)
- Minimap with click-to-pan
- Flow validation with error highlighting
- Import/Export flows as JSON
- Campaign delivery funnel visualization
- Per-contact delivery status tracking
- Multi-inbox bot support
