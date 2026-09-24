# Changelog

## [Unreleased]

### Security
- Bot Builder: stored XSS on the bot list — `active` and `created_at` were printed unescaped and taken from the request body; both are now server-owned and escaped.
- Bot engine: outbound requests (webhook node, image/video download) go through Chatwoot's `SafeFetch` when available, so a redirect can no longer reach internal addresses (cloud metadata, `rails:3000`). Older Chatwoot keeps the DNS check and stops following redirects.
- Bot engine: `bot_state` lives in conversation custom attributes, which a website visitor can overwrite. It is now signed with the server secret, and menus, delays and waits only run for an active bot of the conversation's own account.
- Bot engine: the assign node only picks agents and teams of the conversation's account; the `contact_field` condition reads a fixed list of fields instead of calling any method named in the flow.
- Campaign Report is limited to account administrators, like Chatwoot's own campaign screen (it lists recipients' names and phone numbers and exports CSV).
- Social Comments: the Page token is no longer stored in the inbox attributes (returned to every inbox agent by the inboxes API). Pages are mapped to inboxes in a registry that account admins cannot edit, so another account can no longer claim a Page.
- Social Comments: outgoing replies are verified with Chatwoot's webhook signature, looked up by the conversation's display id within its inbox, and private notes / private replies are never published.
- Navigation widget is no longer injected into customer-facing pages (website widget, help center, surveys).

### Fixed
- Bot Builder: the "Wait for reply", "API call", "A/B split" and "Go to step" nodes now run (they silently fell through before). Replies and API responses are stored as `{{variable}}`s usable in later messages.
- Bot Builder: the "city" / "country" contact conditions now read the contact's location (they always compared against empty).
- Bot Builder: image/video steps download first and send one message with the file — the message used to go out before the attachment was added.
- Bot Builder: a disabled bot no longer continues after a delay step, and delay loops stop at the execution depth limit.
- Bot Builder: one unreadable bot file no longer disables every bot on the server; bot files are cached by modification time instead of re-read on every incoming message.
- Campaign Report: statistics were always 0 — Chatwoot double-encodes `content_attributes`, which the query did not unwrap. Stats now come from one grouped query instead of four per campaign.
- Social Comments: agent replies were rejected (`401`) because Chatwoot never sends the internal token the endpoint expected, and the conversation was looked up by id instead of display id.
- Social Comments: a commenter whose contact was deleted no longer fails every later comment on the unique `(inbox_id, source_id)` index.
- Social Comments: Graph API calls have 5s/15s timeouts instead of Ruby's 60s defaults.
- Social Comments now serializes duplicate Meta deliveries per inbox and retries one stale-record race instead of creating duplicate conversations.
- Deleted conversations and contacts are treated as clean misses; the middleware no longer dereferences stale associations.
- `nil.id`, `nil.destroy!`, and `ActiveRecord::RecordNotFound` failures from concurrent Chatwoot callbacks are recovered without losing the whole webhook batch.
- Anonymous Facebook commenters receive stable, non-empty contact source IDs instead of being merged into one empty identity.
- A partially failed Meta batch returns `503` for safe retry while already stored comments remain deduplicated.

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
