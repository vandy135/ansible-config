#!/bin/bash
# =============================================================================
# ARCH LINUX ANSIBLE BOOTSTRAP SCRIPT
# =============================================================================
# Run this script on a fresh Arch Linux installation to install Ansible
# and prepare the system for running the playbook.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yourusername/arch-ansible/main/start-here.sh | bash
#   # or
#   ./start-here.sh
#
# After running this script:
#   cd arch-ansible
#   ansible-galaxy install -r requirements.yml
#   ansible-playbook site.yml -l localhost --connection=local
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         ARCH LINUX ANSIBLE BOOTSTRAP                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux only."
        exit 1
    fi
    print_success "Running on Arch Linux"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. Ansible tasks will create a non-root user."
    fi
}

# Update system
update_system() {
    print_step "Updating package database..."
    sudo pacman -Sy --noconfirm

    print_step "Upgrading system packages..."
    sudo pacman -Su --noconfirm
}

# Install required packages
install_packages() {
    print_step "Installing Ansible and dependencies..."

    # Core packages needed for Ansible
    local packages=(
        ansible
        python
        python-pip
        python-passlib    # For password hashing
        git
        openssh
        base-devel        # Needed for AUR helper
    )

    sudo pacman -S --needed --noconfirm "${packages[@]}"

    print_success "Ansible installed: $(ansible --version | head -1)"
}

# Install Ansible Galaxy collections
install_collections() {
    print_step "Installing Ansible Galaxy collections..."

    # Install collections if requirements.yml exists
    if [ -f "requirements.yml" ]; then
        ansible-galaxy install -r requirements.yml
        print_success "Ansible collections installed"
    else
        # Install essential collections manually
        ansible-galaxy collection install community.general
        ansible-galaxy collection install kewlfft.aur
        print_success "Essential collections installed"
    fi
}

# Clone the repository (if not already in it)
clone_repo() {
    local repo_url="${1:-}"

    if [ -f "site.yml" ] && [ -d "roles" ]; then
        print_success "Already in ansible playbook directory"
        return
    fi

    if [ -n "$repo_url" ]; then
        print_step "Cloning repository..."
        git clone "$repo_url" arch-ansible
        cd arch-ansible
        print_success "Repository cloned"
    else
        print_warning "No repository URL provided. Skipping clone."
        print_warning "Make sure to cd into your playbook directory."
    fi
}

# Create local inventory for running on localhost
setup_localhost() {
    print_step "Setting up localhost inventory..."

    # Create host_vars for localhost if it doesn't exist
    mkdir -p inventory/host_vars

    if [ ! -f "inventory/host_vars/localhost.yml" ]; then
        cat > inventory/host_vars/localhost.yml << 'EOF'
---
# Localhost configuration
# Customize these values for your system

system_hostname: archlinux
target_user: "{{ lookup('env', 'USER') }}"

# Adjust these based on your needs
install_desktop: true
install_dev_tools: true
install_cli_tools: true
install_audio: true
install_bluetooth: true
EOF
        print_success "Created inventory/host_vars/localhost.yml"
    fi
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    BOOTSTRAP COMPLETE                        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Review and customize configuration:"
    echo "     vim inventory/host_vars/localhost.yml"
    echo ""
    echo "  2. Run a dry-run to see what will change:"
    echo "     ansible-playbook site.yml -l localhost --connection=local --check --diff"
    echo ""
    echo "  3. Run the full playbook:"
    echo "     ansible-playbook site.yml -l localhost --connection=local"
    echo ""
    echo "  4. Or run specific tags:"
    echo "     ansible-playbook site.yml -l localhost --connection=local --tags 'base,zsh'"
    echo ""
}

# Main execution
main() {
    print_header

    check_arch
    check_root

    update_system
    install_packages

    # If a repo URL is passed as argument, clone it
    clone_repo "${1:-}"

    install_collections
    setup_localhost

    print_next_steps
}

# Run main function with all arguments
main "$@"
