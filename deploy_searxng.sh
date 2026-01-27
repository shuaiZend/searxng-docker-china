#!/bin/bash

# SearXNG Docker deployment script
# Based on the searxng-docker project: https://github.com/searxng/searxng-docker

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose v2."
        exit 1
    fi
    
    print_info "Dependencies check passed."
}

# Generate a random secret key for SearXNG
generate_secret_key() {
    print_info "Generating a new secret key..."
    local secret_key=$(openssl rand -hex 32)
    
    # Update the settings.yml file with the new secret key
    sed -i.bak "s|secret_key:.*|secret_key: \"$secret_key\"|" searxng/settings.yml && rm -f searxng/settings.yml.bak
    
    print_info "Secret key updated in searxng/settings.yml"
}

# Create necessary directories
create_directories() {
    print_info "Creating necessary directories..."

    mkdir -p searxng

    print_info "Directories created."
}

# Initialize the SearXNG instance
init_searxng() {
    print_info "Initializing SearXNG instance..."
    
    # Check if .env file exists, if not create a default one
    if [ ! -f ".env" ]; then
        print_warn ".env file not found. Creating a default one..."
        cat > .env << EOF
# SearXNG 实例的主机名
SEARXNG_HOSTNAME=localhost

# Let's Encrypt 证书注册邮箱
SEARXNG_EMAIL=admin@example.com

# SearXNG 实例管理员密码（可选）
SEARXNG_ADMIN_PASSWORD=

# Redis 密码（可选）
REDIS_PASSWORD=
EOF
        print_info "Created default .env file. Please update it with your settings."
    fi
    
    # Generate secret key if not already done
    if grep -q "ultrasecretkey\|825d3338bfeaf148237c18ea0a3dcfefed667cf8c77e5832738067c2af4c39b0" searxng/settings.yml; then
        generate_secret_key
    fi
    
    print_info "Initialization completed."
}

# Start the SearXNG services
start_services() {
    print_info "Starting SearXNG services..."
    
    docker compose up -d
    
    print_info "Services started. Waiting for initialization..."
    sleep 10
    
    print_info "SearXNG should now be accessible at https://${SEARXNG_HOSTNAME:-localhost}"
}

# Stop the SearXNG services
stop_services() {
    print_info "Stopping SearXNG services..."

    docker compose down

    print_info "Services stopped."
}

# Restart the SearXNG services
restart_services() {
    print_info "Restarting SearXNG services..."

    docker compose restart

    print_info "Services restarted."
}

# Update the SearXNG services
update_services() {
    print_info "Updating SearXNG services..."
    
    git pull origin main || git pull origin master
    docker compose pull
    docker compose up -d
    
    print_info "Services updated."
}

# Show logs
show_logs() {
    print_info "Displaying SearXNG logs..."
    
    docker compose logs -f "$@"
}

# Main function
main() {
    case "${1:-start}" in
        "init")
            check_dependencies
            create_directories
            init_searxng
            ;;
        "start")
            check_dependencies
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "update")
            update_services
            ;;
        "logs")
            shift
            show_logs "$@"
            ;;
        "reinit")
            check_dependencies
            stop_services
            docker volume prune -f
            create_directories
            init_searxng
            start_services
            ;;
        *)
            echo "Usage: $0 {init|start|stop|restart|update|logs|reinit}"
            echo "  init     - Initialize the SearXNG instance"
            echo "  start    - Start the SearXNG services"
            echo "  stop     - Stop the SearXNG services"
            echo "  restart  - Restart the SearXNG services"
            echo "  update   - Pull latest changes and update services"
            echo "  logs     - Show logs (pass service name to view specific service logs)"
            echo "  reinit   - Reinitialize everything (removes data)"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"