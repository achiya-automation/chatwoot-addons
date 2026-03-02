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

# Parse flags
AUTO_YES=false
for arg in "$@"; do
    case "$arg" in
        -y|--yes) AUTO_YES=true ;;
    esac
done

confirm() {
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    read -p "$1 [y/N] " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║   Chatwoot Addons Installer v1.1         ║${NC}"
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

# Detect CSP configuration in reverse proxy
detect_csp() {
    local CSP_NEEDS_UPDATE=false
    local CSP_LOCATION=""

    # Check Caddy
    if command -v caddy &> /dev/null; then
        local CADDYFILE="/etc/caddy/Caddyfile"
        if [ -f "$CADDYFILE" ] && grep -q "Content-Security-Policy" "$CADDYFILE" 2>/dev/null; then
            if ! grep -q "cdn.jsdelivr.net" "$CADDYFILE" 2>/dev/null; then
                CSP_NEEDS_UPDATE=true
                CSP_LOCATION="Caddy ($CADDYFILE)"
            fi
        fi
    fi

    # Check Nginx
    for conf in /etc/nginx/sites-enabled/* /etc/nginx/conf.d/*.conf; do
        if [ -f "$conf" ] && grep -q "Content-Security-Policy" "$conf" 2>/dev/null; then
            if ! grep -q "cdn.jsdelivr.net" "$conf" 2>/dev/null; then
                CSP_NEEDS_UPDATE=true
                CSP_LOCATION="Nginx ($conf)"
            fi
        fi
    done 2>/dev/null

    # Check Apache
    for conf in /etc/apache2/sites-enabled/*.conf /etc/httpd/conf.d/*.conf; do
        if [ -f "$conf" ] && grep -q "Content-Security-Policy" "$conf" 2>/dev/null; then
            if ! grep -q "cdn.jsdelivr.net" "$conf" 2>/dev/null; then
                CSP_NEEDS_UPDATE=true
                CSP_LOCATION="Apache ($conf)"
            fi
        fi
    done 2>/dev/null

    if [ "$CSP_NEEDS_UPDATE" = true ]; then
        echo ""
        print_warning "Content Security Policy (CSP) detected in ${CSP_LOCATION}"
        echo ""
        echo -e "${YELLOW}  The Bot Builder loads JavaScript/CSS from external CDNs.${NC}"
        echo -e "${YELLOW}  Your CSP must allow these domains, or the editor will not load.${NC}"
        echo ""
        echo -e "  Add these domains to your CSP header:"
        echo ""
        echo -e "    ${BOLD}script-src${NC}: add ${BOLD}https://cdn.jsdelivr.net https://unpkg.com${NC}"
        echo -e "    ${BOLD}style-src${NC}:  add ${BOLD}https://cdn.jsdelivr.net https://unpkg.com https://fonts.googleapis.com${NC}"
        echo ""
        echo -e "  Example for ${BOLD}Caddy${NC}:"
        echo "    Content-Security-Policy \"... script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://fonts.googleapis.com; ...\""
        echo ""
        echo -e "  Example for ${BOLD}Nginx${NC}:"
        echo "    add_header Content-Security-Policy \"... script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://fonts.googleapis.com; ...\" always;"
        echo ""
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

        if confirm "Would you like to auto-patch your docker-compose file?"; then
            print_step "Backing up docker-compose file..."
            cp "$COMPOSE_FILE" "${COMPOSE_FILE}.backup.$(date +%Y%m%d%H%M%S)"
            print_success "Backup created"

            print_step "Patching docker-compose file..."

            # Use sed-based patching to preserve original YAML formatting
            MOUNT1="${INITIALIZERS_DIR}/bot_builder.rb:/app/config/initializers/bot_builder.rb:ro"
            MOUNT2="${INITIALIZERS_DIR}/campaign_report_dashboard.rb:/app/config/initializers/campaign_report_dashboard.rb:ro"
            MOUNT3="${INITIALIZERS_DIR}/custom_nav_widget.rb:/app/config/initializers/custom_nav_widget.rb:ro"

            # Detect indentation from existing volume lines
            INDENT=$(grep -m1 '^\s*- .*:/app/' "$COMPOSE_FILE" | sed 's/\(^[[:space:]]*\)- .*/\1/' || echo "      ")

            PATCHED=false
            # For each service with chatwoot image, find its volumes section and append mounts
            while IFS= read -r service_line; do
                service_name=$(echo "$service_line" | sed 's/:.*//' | xargs)
                # Find the last volume line for this service's volumes section
                LAST_VOL_LINE=$(awk -v svc="  ${service_name}:" '
                    $0 ~ svc {found=1; next}
                    found && /^  [a-zA-Z]/ {found=0}
                    found && /volumes:/ {invol=1; next}
                    invol && /^[[:space:]]*- / {lastline=NR}
                    invol && !/^[[:space:]]*- / && !/^[[:space:]]*$/ {invol=0}
                    END {print lastline}
                ' "$COMPOSE_FILE")

                if [ -n "$LAST_VOL_LINE" ] && [ "$LAST_VOL_LINE" -gt 0 ]; then
                    sed -i "${LAST_VOL_LINE}a\\
${INDENT}- ${MOUNT1}\\
${INDENT}- ${MOUNT2}\\
${INDENT}- ${MOUNT3}" "$COMPOSE_FILE"
                    print_success "Patched service: ${service_name}"
                    PATCHED=true
                fi
            done < <(grep -B20 'chatwoot/chatwoot' "$COMPOSE_FILE" | grep -E '^  [a-zA-Z_-]+:' | tail -10)

            if [ "$PATCHED" = true ]; then
                print_success "Docker compose patched successfully (original formatting preserved)"
            else
                print_warning "Auto-patch could not find services to patch. Please add the volume mounts manually."
            fi
        fi
    else
        print_success "Volume mounts already configured"
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

# Check CSP configuration
print_step "Checking Content Security Policy..."
detect_csp

# Restart containers
print_step "Restarting Chatwoot containers..."

if confirm "Restart containers now? This will cause brief downtime."; then
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
