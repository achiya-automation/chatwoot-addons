#!/bin/bash
set -e

# ============================================================
# Chatwoot Addons Installer
# One-command installation for Bot Builder + Campaign Report
# ============================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║   Chatwoot Addons Installer v1.0         ║${NC}"
    echo -e "${BLUE}${BOLD}║   Bot Builder + Campaign Report          ║${NC}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

# Default paths
CHATWOOT_ROOT="${CHATWOOT_ROOT:-/opt/chatwoot}"
INITIALIZERS_DIR="${CHATWOOT_ROOT}/custom-initializers"
COMPOSE_FILE=""

# Detect docker compose file
detect_compose() {
    for f in "${CHATWOOT_ROOT}/docker-compose.yaml" "${CHATWOOT_ROOT}/docker-compose.yml" "/root/chatwoot/docker-compose.yaml" "/root/chatwoot/docker-compose.yml"; do
        if [ -f "$f" ]; then
            COMPOSE_FILE="$f"
            return 0
        fi
    done
    return 1
}

# Detect Chatwoot container names
detect_containers() {
    RAILS_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'chatwoot.*rails|rails.*chatwoot' | head -1)
    SIDEKIQ_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E 'chatwoot.*sidekiq|sidekiq.*chatwoot' | head -1)

    if [ -z "$RAILS_CONTAINER" ]; then
        # Try common names
        for name in "chatwoot-rails-1" "chatwoot_rails_1" "chatwoot-rails" "rails"; do
            if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
                RAILS_CONTAINER="$name"
                break
            fi
        done
    fi

    if [ -z "$SIDEKIQ_CONTAINER" ]; then
        for name in "chatwoot-sidekiq-1" "chatwoot_sidekiq_1" "chatwoot-sidekiq" "sidekiq"; do
            if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
                SIDEKIQ_CONTAINER="$name"
                break
            fi
        done
    fi
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header

# Check prerequisites
print_step "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info &> /dev/null 2>&1; then
    print_error "Docker is not running or you don't have permission. Try running with sudo."
    exit 1
fi

detect_containers

if [ -z "$RAILS_CONTAINER" ]; then
    print_error "Could not find Chatwoot Rails container."
    echo "  Make sure Chatwoot is running with Docker."
    echo "  You can set CHATWOOT_ROOT to your Chatwoot installation path."
    exit 1
fi

print_success "Found Chatwoot Rails container: ${RAILS_CONTAINER}"
[ -n "$SIDEKIQ_CONTAINER" ] && print_success "Found Chatwoot Sidekiq container: ${SIDEKIQ_CONTAINER}"

# Create initializers directory
print_step "Setting up custom initializers directory..."
mkdir -p "${INITIALIZERS_DIR}"
print_success "Directory ready: ${INITIALIZERS_DIR}"

# Copy files
print_step "Installing addon files..."

for file in bot_builder.rb campaign_report_dashboard.rb custom_nav_widget.rb; do
    src="${SCRIPT_DIR}/initializers/${file}"
    if [ -f "$src" ]; then
        cp "$src" "${INITIALIZERS_DIR}/${file}"
        print_success "Installed ${file}"
    else
        print_warning "File not found: ${src}"
    fi
done

# Check if volume mounts exist in docker-compose
print_step "Checking Docker volume mounts..."

if detect_compose; then
    NEEDS_MOUNT=false

    if ! grep -q "bot_builder.rb" "$COMPOSE_FILE" 2>/dev/null; then
        NEEDS_MOUNT=true
    fi

    if [ "$NEEDS_MOUNT" = true ]; then
        print_warning "Volume mounts not found in docker-compose file."
        echo ""
        echo -e "${YELLOW}Add these volume mounts to your Chatwoot services (rails, sidekiq, worker):${NC}"
        echo ""
        echo "    volumes:"
        echo "      - ${INITIALIZERS_DIR}/bot_builder.rb:/app/config/initializers/bot_builder.rb:ro"
        echo "      - ${INITIALIZERS_DIR}/campaign_report_dashboard.rb:/app/config/initializers/campaign_report_dashboard.rb:ro"
        echo "      - ${INITIALIZERS_DIR}/custom_nav_widget.rb:/app/config/initializers/custom_nav_widget.rb:ro"
        echo ""

        read -p "Would you like to auto-patch your docker-compose.yaml? [y/N] " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_step "Backing up docker-compose file..."
            cp "$COMPOSE_FILE" "${COMPOSE_FILE}.backup.$(date +%Y%m%d%H%M%S)"
            print_success "Backup created"

            print_step "Patching docker-compose file..."

            # Add volume mounts to services that have 'volumes:' section
            VOLUME_LINES="      - ${INITIALIZERS_DIR}/bot_builder.rb:/app/config/initializers/bot_builder.rb:ro\n      - ${INITIALIZERS_DIR}/campaign_report_dashboard.rb:/app/config/initializers/campaign_report_dashboard.rb:ro\n      - ${INITIALIZERS_DIR}/custom_nav_widget.rb:/app/config/initializers/custom_nav_widget.rb:ro"

            # Use Python for reliable YAML patching
            python3 - "$COMPOSE_FILE" "$INITIALIZERS_DIR" <<'PYEOF'
import sys, yaml

compose_file = sys.argv[1]
init_dir = sys.argv[2]

with open(compose_file, 'r') as f:
    data = yaml.safe_load(f)

mounts = [
    f"{init_dir}/bot_builder.rb:/app/config/initializers/bot_builder.rb:ro",
    f"{init_dir}/campaign_report_dashboard.rb:/app/config/initializers/campaign_report_dashboard.rb:ro",
    f"{init_dir}/custom_nav_widget.rb:/app/config/initializers/custom_nav_widget.rb:ro"
]

services = data.get('services', {})
patched = []

for name, svc in services.items():
    # Only patch Rails-like services (rails, sidekiq, worker)
    image = svc.get('image', '')
    command = str(svc.get('command', ''))
    if 'chatwoot' in image or 'rails' in command or 'sidekiq' in command or 'worker' in command:
        if 'volumes' not in svc:
            svc['volumes'] = []
        existing = [v for v in svc['volumes'] if isinstance(v, str)]
        for mount in mounts:
            if mount not in existing:
                svc['volumes'].append(mount)
        patched.append(name)

with open(compose_file, 'w') as f:
    yaml.dump(data, f, default_flow_style=False, allow_unicode=True, sort_keys=False)

for name in patched:
    print(f"  Patched service: {name}")
PYEOF

            if [ $? -eq 0 ]; then
                print_success "Docker compose patched successfully"
            else
                print_warning "Auto-patch failed. Please add the volume mounts manually."
            fi
        fi
    fi
else
    print_warning "Could not find docker-compose file. Please add volume mounts manually."
    echo ""
    echo "    volumes:"
    echo "      - ${INITIALIZERS_DIR}/bot_builder.rb:/app/config/initializers/bot_builder.rb:ro"
    echo "      - ${INITIALIZERS_DIR}/campaign_report_dashboard.rb:/app/config/initializers/campaign_report_dashboard.rb:ro"
    echo "      - ${INITIALIZERS_DIR}/custom_nav_widget.rb:/app/config/initializers/custom_nav_widget.rb:ro"
    echo ""
fi

# Restart containers
print_step "Restarting Chatwoot containers..."

read -p "Restart containers now? This will cause brief downtime. [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -n "$COMPOSE_FILE" ]; then
        COMPOSE_DIR=$(dirname "$COMPOSE_FILE")
        cd "$COMPOSE_DIR"
        docker compose restart 2>/dev/null || docker-compose restart 2>/dev/null || {
            docker restart "$RAILS_CONTAINER" 2>/dev/null
            [ -n "$SIDEKIQ_CONTAINER" ] && docker restart "$SIDEKIQ_CONTAINER" 2>/dev/null
        }
    else
        docker restart "$RAILS_CONTAINER" 2>/dev/null
        [ -n "$SIDEKIQ_CONTAINER" ] && docker restart "$SIDEKIQ_CONTAINER" 2>/dev/null
    fi

    print_step "Waiting for Chatwoot to start (~30s)..."
    sleep 30

    # Verify
    if docker ps | grep -q "$RAILS_CONTAINER"; then
        print_success "Chatwoot is running!"
    else
        print_warning "Container may still be starting. Check: docker ps"
    fi
else
    print_warning "Skipped restart. Remember to restart Chatwoot to load the addons."
fi

# Print summary
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Bot Builder:${NC}       https://your-chatwoot-domain/bot-builder"
echo -e "  ${BOLD}Campaign Report:${NC}   https://your-chatwoot-domain/campaign-report"
echo ""
echo -e "  Both pages require Chatwoot login."
echo -e "  A navigation sidebar appears on hover (left edge) on all Chatwoot pages."
echo ""
echo -e "  ${BLUE}Logs:${NC} docker logs ${RAILS_CONTAINER} 2>&1 | grep -E 'BotBuilder|CampaignReport|CUSTOM'"
echo ""
